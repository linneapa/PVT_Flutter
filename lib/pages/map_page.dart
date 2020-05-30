import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezsgame/api/Services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'IconInfo.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:flutter/widgets.dart';
import 'SizeConfig.dart';
import 'dart:math' as Math;
import 'package:search_map_place/search_map_place.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' as platform;
import 'package:workmanager/workmanager.dart';
import 'package:ezsgame/callbackDispatcher.dart' as CallbackDispatcher;
import 'package:ezsgame/api/ParkingSpace.dart';


class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState(this.marker);

  MapPage({Key key, this.auth, this.userId, this.logoutCallback, this.marker, this.initPosition})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final Marker marker;
  CameraPosition initPosition;
}

class _MapPageState extends State<MapPage> {

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  var currMarker;

  _MapPageState(this.currMarker);

  bool currentlyNavigating = false;
  bool handicapToggled = false;
  var _globalCarToggled = true;
  var _globalTruckToggled = false;
  var _globalMotorcycleToggled = false;
  var currParking;
  String currentParkingActivity;

  Map<String, Feature> parkMark = Map();
  var parkings;
  final db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  bool duplicate = false;


  SizeConfig sizeConfig;
  Completer<GoogleMapController> _mapController = Completer();
  Location location = Location();
  LocationData _myLocation;
  GoogleMapController _controller;
  StreamSubscription<LocationData> _locationSubscription;
  static Map<String, Marker> _markers = {};
  BitmapDescriptor arrowIcon;
  BitmapDescriptor carIcon;
  BitmapDescriptor handicapIcon;
  BitmapDescriptor motorcycleIcon;
  BitmapDescriptor truckIcon;
  LatLng initLocation = LatLng(59.3293, 18.0686);
  String _error;
  LatLng currentDestination;
  var currentDestinationMarker;
  final weekDays =['Monday', 'Tuesday', 'Wednesday', 'Thursday','Friday','Saturday','Sunday'];
  final hours = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23];

  double _pinPillPosition = -300; // Used in InfoWindow Animation
  // this will hold the generated polylines
  Set<Polyline> _polylines = {};
  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];
  // this is the key object - the PolylinePoints
  // which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    getBytesFromAsset('assets/direction-arrow.png', 64).then((onValue) {
      arrowIcon = BitmapDescriptor.fromBytes(onValue);
    });
    getBytesFromAsset('assets/carAvailableNotFavorite.png', 64).then((onValue) {
      carIcon = BitmapDescriptor.fromBytes(onValue);
    });
    getBytesFromAsset('assets/handicapAvailableNotFavorite.png', 64).then((onValue) {
      handicapIcon = BitmapDescriptor.fromBytes(onValue);
    });
    getBytesFromAsset('assets/motorcycleAvailableNotFavorite.png', 64).then((onValue) {
      motorcycleIcon = BitmapDescriptor.fromBytes(onValue);
    });
    getBytesFromAsset('assets/truckAvailableNotFavorite.png', 64).then((onValue) {
      truckIcon = BitmapDescriptor.fromBytes(onValue);
    });
    //setInitLocation();


    _fcm.configure(
      onMessage: (message) async { //executed if the app is in the foreground
        print(message["notification"]["title"]);

      },


      /*TODO: so these two below are causing problems. These pieces of code should be executed when the user taps the notification
              but they aren't. According to the internet (good source), this is because the notifications (being sent from index.ts)
              doesn't contain data 'FLUTTER_NOTIFICATION_CLICK', but they do, or that the channel name isn't specified in the Manifest, but it is.
              I do think it has something to do with the channels though because it works when I send a notification from the firebase console
      **/
      onResume: (message) async { //executed if the app is in the background and the user taps on the notification
        //remember that needs to send some data with the notification as well, when onResume/onLaunch
         setState(() {showArrivedAtDestinationDialog(); });
         /*TODO: (after the problem above is solved) should open the above dialog but we will need to have saved which parking it regarded
                Maybe can save it if the user exits the feedback dialog until they give the feedback and just not have currentlyNavigating set to true?

          */
         Workmanager.cancelAll();
         print("notification from background.");
        print(message["data"]["title"]);
      },
      onLaunch: (message) async { //executed if the app is terminated and the user taps on the notification
        setState(() {showArrivedAtDestinationDialog(); });
        Workmanager.cancelAll();
        print("notification from background.");
        print(message["data"]["title"]);
      },
    );

    _saveDeviceToken();
  }

  //Individual Device Notifications
    // Get the token, save it to the database for current user so push notifications can be sent to the device
  _saveDeviceToken() async {
    // Get the current user
    var uid = (await widget.auth.getCurrentUser()).uid;

    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      var tokens = db
          .collection('userData')
          .document(uid)
          .collection('tokens')
          .document(fcmToken);

      await tokens.setData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
    //    'platform': Platform.operatingSystem // optional
      });
    }
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  Future<void> _listenLocation() async {
    _locationSubscription =
        location.onLocationChanged.handleError((dynamic err) {
      setState(() {
        _error = err.code;
      });
      _locationSubscription.cancel();
    }).listen((LocationData currentLocation) {
      setState(() {
        // Check if the route needs to be updated
        bool changed = false;
        if (_myLocation != currentLocation) changed = true;
        _myLocation = currentLocation;

        updatePinOnMap();
        if (changed && currentDestination != null) setPolylines();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    sizeConfig = SizeConfig();
    sizeConfig.init(context);
    _listenLocation();
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
            child: Stack(
              children: <Widget>[
                showGoogleMaps(),
                showTopBar(),
                showWindow(),
                showMyLocationButton(),
                showStopRouteButton(), 
                ],
          )
        )
    );
  }

  Widget showTopBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 50),
          ), //empty container to move down the searchfield
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Flexible(child: Container(height: 10,)),
              Expanded(
                child: showSearchTextField(),
                flex: 5,
              ),
              Flexible(child: showFilterButton(), flex: 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget showSearchTextField() {
    return SearchMapPlaceWidget(
        apiKey: "AIzaSyBLNOKl2W5s0vuY0aZ-ll_PNoeldgko12w",
        // The language of the autocompletion
        language: 'se',
        // The position used to give better recomendations.
        location: LatLng(59.3293, 18.0686),
        radius: 30000,
        //darkMode: true,
        placeholder: "Sök gata, adress, etc.",
        onSelected: (Place place) async {
          final geolocation = await place.geolocation;

          // Will animate the GoogleMap camera, taking us to the selected position with an appropriate zoom
          final GoogleMapController controller = await _mapController.future;

          setState(() {
            controller
                .animateCamera(CameraUpdate.newLatLng(geolocation.coordinates));
            controller.animateCamera(
                CameraUpdate.newLatLngBounds(geolocation.bounds, 0));
          });
        });
  }

  Widget showFilterButton() {
    return Container(
      color: const Color(0xF2F2F2).withOpacity(0.9),
      child: IconButton(
        icon: Icon(
          MdiIcons.filterMenu,
          color: Colors.grey
        ),
        onPressed: () {
          createDialog(context);
          showGoogleMaps();
          // do something
        },
        //     ),
      ),
    );
  }

  addToFavorites() async {
    String id = widget.userId;
    bool duplicate = false;

    QuerySnapshot snapshot = await Firestore.instance
        .collection('userData')
        .document(id)
        .collection('favorites')
        .getDocuments();

    for (var v in snapshot.documents) {
      if (v['location'] == currParking.properties.address) {
        duplicate = true;
      }
    }

    print(currParking.geometry.coordinates[0][0]);

    if (!duplicate) {
      await db.collection('userData').document(id).collection('favorites').add(
          {
            'location': currParking.properties.address,
            'district': currParking.properties.cityDistrict,
            'coordinatesX': currParking.geometry.coordinates[0][1],
            'coordinatesY': currParking.geometry.coordinates[0][0],
          }
      );
    }

    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
              title: duplicate ? Text('Misslyckades') : Text("Success"),
              content: duplicate ? Text('Parkeringen finns redan i dina favoriter!') : Text(currParking.properties.address + ' tillagd i favoriter!'));
        });
  }

  String getFormattedTimeInfoString() {
    String timeInfo = DateTime.now().toString();

    String timeInfoDate = timeInfo.substring(0, timeInfo.indexOf(' '));
    String timeInfoClock = timeInfo.substring(timeInfo.indexOf(' ') + 1, timeInfo.lastIndexOf(':'));
    String completeTimeInfo = timeInfoDate + ', kl ' + timeInfoClock;

    return completeTimeInfo;
  }

  addToHistory() async {
    String id = widget.userId;
    bool duplicate = false;

   QuerySnapshot snapshot = await Firestore.instance
       .collection('userData')
       .document(id)
       .collection('history')
       .getDocuments();

   for(var v in snapshot.documents){
     if(v['location'] == currParking.properties.address) {
       db.collection('userData')
           .document(id)
           .collection('history')
           .document(v.documentID)
           .delete();
       duplicate = true;
     }
   }

   await db.collection('userData').document(id).collection('history').add(
     {
       'location': currParking.properties.address,
       'district': currParking.properties.cityDistrict,
       'coordinatesX': currParking.geometry.coordinates[0][1],
       'coordinatesY': currParking.geometry.coordinates[0][0],
       'timestamp': getFormattedTimeInfoString(),
     }
   );
   if(snapshot.documents.length <= 9 && !duplicate){
     //TODO: remove oldest document
   }
  }

  Widget showFavoritesButton() {
    return Container(
      child: FlatButton(
          child:
              Icon(Icons.favorite_border, size: 60, color: Colors.orangeAccent),
          onPressed: () {
            if (currMarker != null) addToFavorites();
          }),
    );
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    parkings = await Services.fetchParkering(null, _globalCarToggled,
        _globalTruckToggled, _globalMotorcycleToggled, handicapToggled);
    _controller = controller;
    _mapController.complete(controller);

    setState(() {
      _markers.clear();
      BitmapDescriptor _icon;
      BitmapDescriptor _selectedIcon;
      if(_globalCarToggled){
        _icon = carIcon;
        print("car toggled");
      }else if(_globalTruckToggled){
        _icon = truckIcon;
        print("truck toggled");
      }else if(_globalMotorcycleToggled){
        _icon = motorcycleIcon;
        print("cycle toggled");
      }

      for (final parking in parkings.features) {
        _selectedIcon = _icon;
        if(handicapToggled){
          if(parking.properties.vfPlatsTyp == "Reserverad p-plats rörelsehindrad"){
            _selectedIcon = handicapIcon;
            print("handicap toggled");
          }
        }
        final marker = Marker(
          onTap: () {
            _onMarkerTapped(parking);
          },
          markerId: MarkerId(parking.properties.address),
          position: LatLng(parking.geometry.coordinates[0][1],
              parking.geometry.coordinates[0][0]),
          icon: _selectedIcon,
        );
        _markers[parking.properties.address] = marker;
        parkMark[parking.properties.address] = parking;
      }
      updatePinOnMap();
    });
  }

  Widget showGoogleMaps() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      polylines: _polylines,
      initialCameraPosition: widget.initPosition,
      markers: _markers.values.toSet(),
      onTap: (LatLng location) {
        setState(() {
          currMarker = null;
        });
      },
    );
  }

  // Animated info window
  Widget showWindow() {
    if (currMarker != null) {
      return AnimatedPositioned(
        bottom: 40,
        right: 0,
        left: 0,
        duration: Duration(milliseconds: 100),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal, right: SizeConfig.blockSizeHorizontal, bottom: SizeConfig.blockSizeVertical * 3.5),
            height: SizeConfig.blockSizeVertical * 25,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withOpacity(0.5),
                  )
                ]),
            child: Column(
              children: <Widget>[
                 currParking != null
                     ? _buildLocationInfo()
                     : _buildSimpleLocationInfo()
                ,
                _showFavBtnAndDirectionBtn(),
              ],
            ),
          ),
        ),
      );
    }else {
      return Container();
    }
  }

  Widget _buildLocationInfo() {
    getParkingActivity(currParking.properties.address);
      return Container(
          margin: EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                currParking.properties.address == null
                    ? ' '
                    : currParking.properties.address,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                currParking.properties.cityDistrict == null
                    ? 'Stadsdel '
                    : 'Stadsdel: ' + currParking.properties.cityDistrict,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                currParking.properties.otherInfo == null
                    ? 'Info: '
                    : 'Info: ' + currParking.properties.otherInfo,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                currParking.properties.maxHours == null
                    ? 'Max antal timmar: '
                    : 'Max antal timmar: ' + currParking.properties.maxHours.toString(),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text('Snitt aktivitet: $currentParkingActivity',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ));
  }

  void getParkingActivity(String parking) async{
    int noOfHighRatings = await getAmountOfHighTrafficRatingsForParking(parking);
    int noOfLowRatings = await getAmountOfLowTrafficRatingsForParking(parking);
    int totalNoOfRatings = noOfHighRatings+noOfLowRatings;

    if(totalNoOfRatings <= 0) {
      currentParkingActivity = "Data saknas";
      return;
    }

    double percentageHighRatings = (noOfHighRatings/totalNoOfRatings);

    if(percentageHighRatings < (1/3))
      currentParkingActivity = "Låg aktivitet";
    else if(percentageHighRatings < (2/3))
      currentParkingActivity = "Medium aktivitet";
    else
      currentParkingActivity = "Hög aktivitet";
  }

  Widget _buildSimpleLocationInfo() {
    String name = currMarker.toString().split(":")[2].split("}")[0].trim();
    if (parkMark.containsKey(name)){
      currParking = parkMark[name];
      return _buildLocationInfo();
    }else{
//      parkings = await Services.fetchParkering(null, _globalCarToggled,
//          _globalTruckToggled, _globalMotorcycleToggled, handicapToggled);
      print(name);

    }
    return Container(
        margin: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              currMarker.toString().split(":")[2].split("}")[0],
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ));
  }
//
//  Future<void> (Marker marker) async


  Widget showChooseParkingBtn() {
    return Container(
      margin: EdgeInsets.only(left: 5, right: 10, top: 10),
      child: FlatButton(
        onPressed: () {
          addToHistory();
          navigateMe();
        },
        child: Text(isAlreadyNavigatingHere()? 'Välj bort':'Välj Parkering',
            style: TextStyle(color: Colors.orangeAccent)),
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Colors.orangeAccent, width: 1, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }

  navigateMe() {
    if (!currentlyNavigating) {
      startRoute(LatLng(currParking.geometry.coordinates[0][1],
          currParking.geometry.coordinates[0][0]), currParking.properties.address);
    } else if(isAlreadyNavigatingHere()) {
      if (distanceBetweenPoints(_myLocation.latitude, _myLocation.longitude, currentDestination.latitude, currentDestination.longitude) < 150)
        showChooseAnotherParkingDialog();
      stopCurrentRoute();
    } else {
      if (distanceBetweenPoints(_myLocation.latitude, _myLocation.longitude, currentDestination.latitude, currentDestination.longitude) < 150)
        showChooseAnotherParkingDialog();
      stopCurrentRoute();
      startRoute(LatLng(currParking.geometry.coordinates[0][1],
          currParking.geometry.coordinates[0][0]), currParking.properties.address);

    }
  }

  bool isAlreadyNavigatingHere() {
    return (currentDestination != null && currentDestination.latitude.toStringAsFixed(6) == currParking.geometry.coordinates[0][1].toStringAsFixed(6) && currentDestination.longitude.toStringAsFixed(6) == currParking.geometry.coordinates[0][0].toStringAsFixed(6));
  }

  Widget _showFavBtnAndDirectionBtn() {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          child: showChooseParkingBtn(),
          alignment: Alignment.bottomLeft,
        ),
        Container(
          child: showFavoritesButton(),
          alignment: Alignment.bottomRight,
        ),
      ],
    ));
  }

  _onMarkerTapped(var parking) {
    if (_markers.containsKey(parking.properties.address)) {
      final marker = _markers[parking.properties.address];
      currMarker = marker;
      currParking = parking;
    }
  }

  void showChooseAnotherParkingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)),
          side: BorderSide(color: Colors.black, width: 1),),
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                  Text(
                    "\n  Varför valde du bort denna  \nparkering?\n", textAlign: TextAlign.center, style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  showParkingOccupiedBtn(),
                  Text("               "), //ugly solution but it refused to seperate the btns for some reason
                  showAnotherReasonBtn(),
                ],
              ),
            ],
          ),
          ]
        );
      },
    );
  }

  Widget showParkingOccupiedBtn() {
    return ButtonTheme(
      minWidth: 100.0,
      height: 50.0,
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)) , side: BorderSide(color: Colors.grey, width: 2)),
         color: Colors.white,
        child: new Text("Upptagen", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.of(context).pop();
          reportTraffic(true);
        },
      ),
    );
  }

  Widget showAnotherReasonBtn() {
    return ButtonTheme(
      minWidth: 100.0,
      height: 50.0,
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)) , side: BorderSide(color: Colors.grey, width: 2)),
        color: Colors.white,
        child: new Text("Annan\nanledning", textAlign: TextAlign.center ,style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<int> getAmountOfHighTrafficRatingsForParking(String parkingAdress) async {
    int noOfHighRatings = -1;
    await db.collection('trafficData').document(parkingAdress).collection('high').
      getDocuments().then((value) {
        noOfHighRatings = value.documents.length;
      });
    return noOfHighRatings;
  }

  Future<int> getAmountOfLowTrafficRatingsForParking(String parkingAdress) async {
    int noOfLowRatings = -1;
    await db.collection('trafficData').document(parkingAdress).collection('low').
      getDocuments().then((value) {
        noOfLowRatings = value.documents.length;
      });
    return noOfLowRatings;
  }

  //returns amount of high traffic ratings between specified hours (although cannot be an interval longer than 10 hours... :) ) (and yes, it has an incredibly long name)
  Future<int> getAmountOfHighTrafficRatingsForParkingDuringCertainHours(String parkingAdress, int fromHour, int untilHour) async {
    int noOfHighRatings = -1;
    var tempHoursList = fromHour < untilHour? hours.sublist(fromHour, untilHour) : hours.sublist(0, untilHour) + hours.sublist(fromHour, hours.length);
    await db.collection('trafficData').document(parkingAdress).collection('high').
      where("hour", whereIn: tempHoursList).getDocuments().then((value) {
        noOfHighRatings = value.documents.length;
      });
    return noOfHighRatings;
  }

  void reportTraffic(bool isTraffic) async {
    String id = widget.userId;

    String location = currentDestinationMarker.markerId.toString();
    location = location.substring(location.indexOf(":") + 1);
    location = location.substring(0, location.indexOf("}"));
    location = location.trim();

    DateTime now = new DateTime.now();

    int weekDayNumber = now.weekday;
    String weekDay = weekDays[weekDayNumber-1];
    int hourOfDay = now.hour;
    String date = "${now.year}${now.month}${now.day}";
    bool leftFeedbackHereRecently = false;

    //check if user has left feedback here recently
    await db.collection('trafficData').document(location).collection('high').
            where("byUser", isEqualTo: id).where("date", isEqualTo: date).where("hour", isEqualTo: hourOfDay).getDocuments().then((value) {
              if(value.documents.isNotEmpty)
                leftFeedbackHereRecently = true;
            });
    if(leftFeedbackHereRecently)
        await db.collection('trafficData').document(location).collection('low').
            where("byUser", isEqualTo: id).where("date", isEqualTo: date).where("hour", isEqualTo: hourOfDay).getDocuments().then((value) {
              if(value.documents.isNotEmpty)
                leftFeedbackHereRecently = true;
            });

    if(!leftFeedbackHereRecently) {
      await db.collection('trafficData').document(location).collection(isTraffic? 'high':'low').add(
        {
          'weekDay': weekDay,
          'hour' : hourOfDay,
          'byUser': id,
          'date': date,
        }
      );

      showDialog(
          context: context,
          builder: (_) => AlertDialog(
              title: Text('Tack för din feedback!'),
          ),
      );
    } else {
            showDialog(
          context: context,
          builder: (_) => AlertDialog(
              title: Text('Du har lämnat feedback här nyligen!'),
          ),
      );
    }
  }

  Widget showMuchTrafficBtn() {
    return ButtonTheme(
      minWidth: 100.0,
      height: 50.0,
      child: RaisedButton(
        elevation: 10,
        color: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        child: new Text("Hög", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        onPressed: () {
          Navigator.of(context).pop();
          reportTraffic(true);
        },
      ),
    );
  }

  Widget showNotMuchTrafficBtn() {
    return ButtonTheme(
      minWidth: 100.0,
      height: 50.0,
      child: new RaisedButton(
        // highlightColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        color: Colors.greenAccent,
         child: Text("Låg", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        onPressed: () {
          Navigator.of(context).pop();
          reportTraffic(false);
        },
      ),
    );
  }

  Widget showExitArrivedAtDestinationWindow() {
    return FlatButton(
      onPressed: () {
        startBackgroundExecution(); //men då måste spara addressen
        Navigator.of(context).pop();
      },
      child: Icon(Icons.close, color: Colors.black54, size: 30),
    );
  }

  void showArrivedAtDestinationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)),
          side: BorderSide(color: Colors.black, width: 1),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget> [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget> [
                  showExitArrivedAtDestinationWindow()
                ]
              ),
              Text(
                "Du har anlänt vid din destination!", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                "Var snäll och svara om parkeringen är högtrafikerad.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16),
              ),
              Row(children: <Widget> [Text('')]), //Empty row for extra space
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  showMuchTrafficBtn(),
                  //Text("              "),
                  showNotMuchTrafficBtn(),
                ],
              ),
            ]
          ),
        );
      },
    );
  }

  void startBackgroundExecution() async {
    String uid = (await widget.auth.getCurrentUser()).uid;

    //cleaning up ev. old document
    await db.collection('pushNotifications').document(uid).delete();

    Workmanager.initialize(
        CallbackDispatcher.callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );

    //using the time to get a unique name, otherwise the tasks starts acting funny
    Workmanager.registerOneOffTask(DateTime.now().toIso8601String(), "simpleTask",     inputData: {
     // 'lat': currentDestination.latitude,
     // 'long': currentDestination.longitude,
      'uid': uid,
    }, initialDelay: Duration(minutes: 20));
  }

  void startRoute(LatLng destination, String destinationAdress) async{
    Workmanager.cancelAll(); //to avoid situations where users get lots of push notifications
    if (_markers.containsKey(destinationAdress))
      currentDestinationMarker = _markers[destinationAdress];
    currentDestination = destination;
    setPolylines();
    currentlyNavigating = true;
    setState(() {});
  }

  void stopCurrentRoute() {
    polylineCoordinates.clear();
    _polylines.clear();
    currentDestination = null;
    currentlyNavigating = false;
    setState(() {});
  }

  bool reachedDestination() {
    int radius = 15;
    //checks if myLocation is within a x meters radius from destination
    if (distanceBetweenPoints(_myLocation.latitude, _myLocation.longitude,
            currentDestination.latitude, currentDestination.longitude) <
        radius) {
      showArrivedAtDestinationDialog();
      stopCurrentRoute();
      return true;
    }
    return false;
  }

  //converts degrees to radians
  double degToRad(deg) {
    return deg * (Math.pi / 180);
  }

  //uses the Haversine formula to calculate the distance between two points on the map in meters
  double distanceBetweenPoints(
      double latA, double lonA, double latB, double lonB) {
    int R = 6371000; // Radius of the earth in meters
    double dLat = degToRad(latB - latA);
    double dLon = degToRad(lonB - lonA);
    double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(degToRad(latA)) *
            Math.cos(degToRad(latB)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);
    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    double d = R * c; // Distance in meters
    return d;
  }

  void setPolylines() async {
    if (reachedDestination()) return;
    List<PointLatLng> result =
        (await polylinePoints?.getRouteBetweenCoordinates(
                "AIzaSyBLNOKl2W5s0vuY0aZ-ll_PNoeldgko12w",
                PointLatLng(_myLocation.latitude, _myLocation.longitude),
                PointLatLng(
                    currentDestination.latitude, currentDestination.longitude)))
            .points;
    if (result.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      polylineCoordinates.clear();
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      Polyline polyline = Polyline(
          polylineId: PolylineId("poly"),
          color: Color.fromARGB(255, 40, 122, 198),
          //color: Color.fromARGB(255, 255, 165, 0), orange
          points: polylineCoordinates);

      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map
      _polylines.add(polyline);
    });
  }

  Widget showMyLocationButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FloatingActionButton(
          child: Icon(Icons.my_location, color: Colors.black),
          backgroundColor: Color.fromRGBO(160, 160, 160, 1.0),
          onPressed: () {
            showCurrentLocation(_controller);
          }),
    );
  }

  Widget showStopRouteButton() {
    if (currentlyNavigating)
      return Align(
        alignment: Alignment.bottomLeft,
        child: FloatingActionButton(
            child: Text("Stopp", style: TextStyle(color: Colors.white)),
            backgroundColor: Color.fromRGBO(255, 165, 0, 1.0),
            onPressed: () {
              stopCurrentRoute();
            }),
      );
    else
      return Container(height: 0.0);
  }

  void showCurrentLocation(GoogleMapController controller) async {
    _myLocation = await location.getLocation();
    _controller = controller;
    _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
        bearing: 0,
        target: LatLng(_myLocation.latitude, _myLocation.longitude),
        tilt: 0,
        zoom: 16)));
  }

  void setInitLocation() async {
    initLocation = await getCurrentLocation();
  }

  Future<LatLng> getCurrentLocation() async {
    _myLocation = await location.getLocation();
    return LatLng(_myLocation.latitude, _myLocation.longitude);
  }

  void updatePinOnMap() async {
    _markers['PhoneLocationMarker'] = Marker(
        markerId: MarkerId('PhoneLocationMarker'),
        position: LatLng(_myLocation.latitude, _myLocation.longitude),
        //rotation: _myLocation.heading,                                  //acting funny
        icon: arrowIcon);
  }

  createDialog(BuildContext context) {
    // The following code is for the filter popup page.
    showDialog(
      context: context,
      builder: (context) {
        return ChangeNotifierProvider(
          create: (context) => IconInfo(
              _globalCarToggled, _globalTruckToggled, _globalMotorcycleToggled),
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Filter",
                            style: TextStyle(
                              fontSize: 17,
                              decoration: TextDecoration.underline,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          CarIconButton(),
                          TruckIconButton(),
                          MotorcycleIconButton()
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          showHandicapIconButton(),
                          showCloseButton(context),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ).then((val) {
      // retrieve and update the state of the icons
      IconInfo ic = val;
      if (ic != null) {
        _globalMotorcycleToggled = ic.motorcycleToggled;
        _globalTruckToggled = ic.truckToggled;
        _globalCarToggled = ic.carToggled;
      }
    });
  }

  Widget showHandicapIconButton() {
    return StatefulBuilder(builder: (context, setState) {
      return Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          iconSize: 50,
          icon: Icon(
            Icons.accessible,
            color: handicapToggled ? Colors.orangeAccent : Colors.grey,
          ),
          onPressed: () => setState(() => handicapToggled = !handicapToggled),
        ),
      );
    });
  }

  Widget showCloseButton(BuildContext context) {
    var iconInfo = Provider.of<IconInfo>(context);
    return StatefulBuilder(builder: (context, setState) {
      return OutlineButton(
        borderSide: BorderSide(color: Colors.grey, width: 2),
        onPressed: () => {
          _onMapCreated(_controller),
          Navigator.pop(context, iconInfo),
        },
        child: Text("Stäng", style: TextStyle(fontSize: 17)),
      );
    });
  }
}

class CarIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var iconInfo = Provider.of<IconInfo>(context);
    return IconButton(
        iconSize: 50,
        icon: Icon(
          Icons.directions_car,
          color: iconInfo.carToggled ? Colors.orangeAccent : Colors.grey,
        ),
        onPressed: () {
          iconInfo.car = !iconInfo.carToggled;

          bool truckValue = iconInfo.truckToggled;
          if (truckValue) iconInfo.truck = !truckValue;

          bool motorcycleValue = iconInfo.motorcycleToggled;
          if (motorcycleValue) iconInfo.motorcycle = !motorcycleValue;
        });
  }
}

class TruckIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var iconInfo = Provider.of<IconInfo>(context);
    return IconButton(
        iconSize: 50,
        icon: Icon(
          MdiIcons.truck,
          color: iconInfo.truckToggled ? Colors.orangeAccent : Colors.grey,
        ),
        onPressed: () {
          iconInfo.truck = !iconInfo.truckToggled;

          bool carValue = iconInfo.carToggled;
          if (carValue)
            iconInfo.car = !carValue;

          bool motorcycleValue = iconInfo.truckToggled;
          if (motorcycleValue)
            iconInfo.motorcycle = !motorcycleValue;

        }
    );
  }
}

class MotorcycleIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var iconInfo = Provider.of<IconInfo>(context);
    return IconButton(
        iconSize: 50,
        icon: Icon(
          Icons.motorcycle,
          color: iconInfo.motorcycleToggled ? Colors.orangeAccent : Colors.grey,
        ),
        onPressed: () {
          iconInfo.motorcycle = !iconInfo.motorcycleToggled;

          bool carValue = iconInfo.carToggled;
          if (carValue) iconInfo.car = !carValue;

          bool truckValue = iconInfo.truckToggled;
          if (truckValue) iconInfo.truck = !truckValue;
        });
  }
}
