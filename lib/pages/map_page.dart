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
import 'map_marker.dart';
import 'map_helper.dart';
import 'package:fluster/fluster.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' as platform;
import 'package:workmanager/workmanager.dart';
import 'package:ezsgame/callbackDispatcher.dart' as CallbackDispatcher;
import 'package:ezsgame/api/ParkingSpace.dart';



class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState(this.doc);

  MapPage({Key key, this.auth, this.userId, this.logoutCallback, this.doc, this.initPosition})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final DocumentSnapshot doc;
  CameraPosition initPosition;
}

class _MapPageState extends State<MapPage>{


  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  DocumentSnapshot doc;
  _MapPageState(this.doc);

  bool rendering = false;
  bool showClusters = false;
  bool newToggle = false;
  bool _isLoading = true;
  var currMarker;
  bool currentlyNavigating = false;
  var _globalHandicapToggled = false;
  var _globalCarToggled = true;
  var _globalTruckToggled = false;
  var _globalMotorcycleToggled = false;
  var currParking;
  String currentDestinationAddress;
  String currentParkingActivity;
  double latestLong;
  double latestLat;
  double latestZoom = 12.0;
  CameraPosition cameraPosition;

  Map<String, Feature> parkMark = Map();
  var singlePark;
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


  final Map<String, Marker> _markers = Map();
  Fluster<MapMarker> _clusterManager;
  double _currentZoom;

  final Color _clusterColor = Colors.blue;    //Color of cluster circle
  final Color _clusterTextColor = Colors.white;   //Color of cluster text


  BitmapDescriptor arrowIcon;
  BitmapDescriptor carIcon;
  BitmapDescriptor handicapIcon;
  BitmapDescriptor motorcycleIcon;
  BitmapDescriptor truckIcon;
  BitmapDescriptor currentIcon;
  BitmapDescriptor selectedIcon;
  BitmapDescriptor carSelectedIcon;
  BitmapDescriptor motorcycleSelectedIcon;
  BitmapDescriptor truckSelectedIcon;
  BitmapDescriptor handicapSelectedIcon;
  LatLng initLocation = LatLng(59.3293, 18.0686);
  String _error;
  LatLng currentDestination;
  var currentDestinationMarker;
  String formerDestination;
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
    getBytesFromAsset('assets/carOnMapSelected.png', 84).then((onValue) {
      carSelectedIcon = BitmapDescriptor.fromBytes(onValue);
    });
    getBytesFromAsset('assets/handicapOnMapSelected.png', 84).then((onValue) {
      handicapSelectedIcon = BitmapDescriptor.fromBytes(onValue);
    });
    getBytesFromAsset('assets/motorcycleOnMapSelected.png', 84).then((onValue) {
      motorcycleSelectedIcon = BitmapDescriptor.fromBytes(onValue);
    });
    getBytesFromAsset('assets/truckOnMapSelected.png', 84).then((onValue) {
      truckSelectedIcon = BitmapDescriptor.fromBytes(onValue);
    });


    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async { //executed if the app is in the foreground
        print((message["notification"]["title"]).substring(23));

      },
      onResume: (Map<String, dynamic> message) async { //executed if the app is in the background and the user taps on the notification
           showArrivedEarlierAtDestinationDialog();
      },
      onLaunch: (Map<String, dynamic> message) async { //executed if the app is terminated and the user taps on the notification
          showArrivedEarlierAtDestinationDialog();

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
                _showCircularProgress(),
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
          // do something
        },
        //     ),
      ),
    );
  }

  String getVehicleType() {

    if (currentIcon == carIcon) {
      return 'bil';
    }
    else if (currentIcon == motorcycleIcon) {
      return 'motorcykel';
    }
    else if (currentIcon == truckIcon) {
      return 'lastbil';
    }
    else if (currentIcon == handicapIcon) {
      return 'handicap';
    }
    return 'bil';
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


    String district = currParking.properties.cityDistrict == null ? 'saknas' : currParking.properties.cityDistrict;
    String info = currParking.properties.otherInfo == null ? 'saknas' : currParking.properties.otherInfo;
    String maxTimmar = currParking.properties.maxHours == null ? 'saknas' : currParking.properties.maxHours.toString();

    if (!duplicate) {
      await db.collection('userData').document(id).collection('favorites').add(
          {
            'location': currParking.properties.address,
            'district': district,
            'coordinatesX': currParking.geometry.coordinates[0][1],
            'coordinatesY': currParking.geometry.coordinates[0][0],
            'info': info,
            'maxTimmar': maxTimmar,
            'vehicleType': getVehicleType()
          }
      );
    }

    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(milliseconds: 2000), () {
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
       .collection('history').orderBy('timestamp', descending: true)
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

    String district = currParking.properties.cityDistrict == null ? 'saknas' : currParking.properties.cityDistrict;
    String info = currParking.properties.otherInfo == null ? 'saknas' : currParking.properties.otherInfo;
    String maxTimmar = currParking.properties.maxHours == null ? 'saknas' : currParking.properties.maxHours.toString();

   await db.collection('userData').document(id).collection('history').add(
     {
       'location': currParking.properties.address,
       'district': district,
       'coordinatesX': currParking.geometry.coordinates[0][1],
       'coordinatesY': currParking.geometry.coordinates[0][0],
       'timestamp': getFormattedTimeInfoString(),
       'info': info,
       'maxTimmar': maxTimmar,
       'vehicleType': getVehicleType()
     }
   );
    if(snapshot.documents.length+1 > 10){
      db
          .collection('userData')
          .document(id)
          .collection('history')
          .document(snapshot.documents.last.documentID)
          .delete();
   }
  }

  Widget showFavoritesButton() {
    return Container(
      child: FlatButton(
          child:
              Icon(Icons.favorite_border, size: 60, color: Colors.orangeAccent),
          onPressed: () {
            if (currMarker != null) addToFavorites();
            Future.delayed(const Duration(milliseconds: 1500), () {
              currMarker = null;
            }
            );
          }),
    );
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container( height: 0.0, width: 0.0, );
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
      parkings = await Services.fetchParkering(null, null, _globalCarToggled,
          _globalTruckToggled, _globalMotorcycleToggled, _globalHandicapToggled);
      _controller = controller;
      _mapController.complete(controller);
      double zoom = await controller.getZoomLevel();
      if (showClusters){
        _initMarkers(zoom);
      }else{
        _newMarkers(null);
      }
      setState(() {
        _isLoading = false;
      });
  }

  Future<void> _newMarkers(CameraPosition position) async {
    if (doc != null){
      doc == null;
      return;
    }

    double change = 0;
    double zoomChange = 0;
    if (position != null){
      zoomChange = (position.zoom - latestZoom).abs();
      print('newMarkers positionzoom ' + position.zoom.toString());
      print('zoomchange ' + zoomChange.toString());
      if (latestLong != null){
        double longChange = (position.target.longitude - latestLong).abs();
        double latChange = (position.target.latitude - latestLat).abs();
        change = longChange + latChange;
        print('change ' + change.toString());
      }
    }


    if (zoomChange == 1 || newToggle || position == null){
      print('changing');
      print('currentZoom ' + latestZoom.toString());
      print('newToggle ' + newToggle.toString());
      if (position != null){
        latestZoom = position.zoom;
        if (change > 0.005){
          latestLat = position.target.latitude;
          latestLong = position.target.longitude;
        }
      }

      setState(() {
        _isLoading = true;
      });
      if (showClusters){
        if (_clusterManager != null && !newToggle) {
          print('updating cluster markers');
          _updateMarkers(position.zoom);
        } else {
          _markers.clear();
          parkings = await Services.fetchParkering(null, null, _globalCarToggled,
              _globalTruckToggled, _globalMotorcycleToggled, _globalHandicapToggled);
          _initMarkers(position.zoom);
        }
      }else if((!showClusters && position == null) || newToggle || (rendering && position.zoom > 13 && change > 0.005)){
          parkings = await Services.fetchParkering(null, position, _globalCarToggled,
              _globalTruckToggled, _globalMotorcycleToggled, _globalHandicapToggled);
          setState(() {
            _markers.clear();
            _clusterManager = null;
            BitmapDescriptor _icon;
            if(_globalCarToggled){
              currentIcon = carIcon;
              selectedIcon = carSelectedIcon;
            }else if(_globalTruckToggled){
              currentIcon = truckIcon;
              selectedIcon = truckSelectedIcon;
            }else if(_globalMotorcycleToggled){
              currentIcon = motorcycleIcon;
              selectedIcon = motorcycleSelectedIcon;
            }else if(_globalHandicapToggled){
              currentIcon = handicapIcon;
              selectedIcon = handicapSelectedIcon;
            }

            if (parkings != null){
              int counter = 0;
              for (final parking in parkings.features) {
                _icon = currentIcon;
                if (_globalCarToggled){
                  if (parking.properties.vfPlatsTyp == "Reserverad p-plats rörelsehindrad"){
                    continue;
                  } else if (parking.properties.vfPlatsTyp == "Reserverad p-plats lastbil"){
                    continue;
                  } else if (parking.properties.vfPlatsTyp == "Reserverad p-plats motorcykel"){
                    continue;
                  }
                }
                if ((parking.properties.address != '<Adress saknas>' &&
                    parking.properties.vfMeter != null) ||
                    !_globalCarToggled ||
                    (rendering && position != null && position.zoom > 13)
                ) {

                  counter ++;
                  final marker = Marker(
                    onTap: () {
                      updateCurrentMarker(parking);
                    },
                    markerId: MarkerId(parking.properties.address),
                    position: LatLng(parking.geometry.coordinates[0][1],
                        parking.geometry.coordinates[0][0]),
                    icon: _icon,
                  );
                  _markers[parking.properties.address] = marker;
                  parkMark[parking.properties.address] = parking;
                }
              }
              print('loaded ' + counter.toString() + ' to screen');
            }
            updatePinOnMap();
          });
        }
      }
      setState(() {
        _isLoading = false;
        newToggle = false;
      });
  }

  Widget showGoogleMaps() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      onCameraMove: (position) {
        _newMarkers(position);
        _updateCamera(position);
      },
      polylines: _polylines,
      initialCameraPosition: widget.initPosition,
      markers: _markers.values.toSet(),
      onTap: (LatLng location) {
        updateCurrentMarker(null);
      },
    );
  }

  _updateCamera(CameraPosition position){
    cameraPosition = position;
  }

  // Animated info window
  Widget showWindow() {
    if (currParking == null && doc != null){
      //String name = currMarker.toString().split(":")[2].split("}")[0].trim();
      if (parkMark.containsKey(doc['location'])){
        updateCurrentMarker(parkMark[doc['location']]);
      }else{
        upDateParking();
      }
    }
    if (currMarker != null && currParking != null) {
      return AnimatedPositioned(
        bottom: 0,
        right: 47,
        left: 0,
        duration: Duration(milliseconds: 100),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1.2, bottom: SizeConfig.blockSizeVertical),
            margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal, right: SizeConfig.blockSizeHorizontal, bottom: SizeConfig.blockSizeVertical),
            //height: SizeConfig.blockSizeVertical * 28,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(35)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withOpacity(0.5),
                  )
                ]),
            child: Column(
              children: <Widget>[
                _buildLocationInfo(),
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
          margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                currParking.properties.address == null
                    ? '\r'
                    : currParking.properties.address,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                currParking.properties.cityDistrict == null
                    ? '\r'
                    : 'Stadsdel: ' + currParking.properties.cityDistrict,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                currParking.properties.otherInfo == null
                    ? '\r'
                    : 'Info: ' + currParking.properties.otherInfo,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                currParking.properties.maxHours == null
                    ? '\r'
                    : 'Max antal timmar: ' + currParking.properties.maxHours.toString(),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text('Aktivitet: $currentParkingActivity',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
      currentParkingActivity = "Sällan upptagen";
    else if(percentageHighRatings < (2/3))
      currentParkingActivity = "Upptagen ibland";
    else
      currentParkingActivity = "Ofta upptagen";
  }

  Widget _buildSimpleLocationInfo() {
    String name = currMarker.toString().split(":")[2].split("}")[0].trim();
    if (parkMark.containsKey(name)) {
      currParking = parkMark[name];
      return _buildLocationInfo();
    } else {
//      parkings = await Services.fetchParkering(null, _globalCarToggled,
//          _globalTruckToggled, _globalMotorcycleToggled, handicapToggled);
      print(name);
    }
  }
  Future<void> upDateParking() async {
    singlePark = await Services.fetchParkering(doc, null, _globalCarToggled,
        _globalTruckToggled, _globalMotorcycleToggled, _globalHandicapToggled);

    print(singlePark);
    for (final parking in singlePark.features) {
      print(parking.properties.address);
      if (parking.properties.address == doc['location']) {
        updateCurrentMarker(parking);
      }
    }
  }

  Widget showChooseParkingBtn() {
    return Container(
      margin: EdgeInsets.only(left: 5, right: 10, top: 10),
      child: FlatButton(
        onPressed: () {
          addToHistory();
          navigateMe();
          currMarker = null;
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          child: showChooseParkingBtn(),
          alignment: Alignment.bottomLeft,
        ),
        Container(
          padding: EdgeInsets.only(right: SizeConfig.blockSizeHorizontal * 2.5),
          child: showFavoritesButton(),
          alignment: Alignment.bottomRight,
        ),
      ],
    ));
  }

  updateCurrentMarker(var parking){
    if(_globalCarToggled){
      currentIcon = carIcon;
      selectedIcon = carSelectedIcon;
    }else if(_globalTruckToggled){
      currentIcon = truckIcon;
      selectedIcon = truckSelectedIcon;
    }else if(_globalMotorcycleToggled){
      currentIcon = motorcycleIcon;
      selectedIcon = motorcycleSelectedIcon;
    }else if(_globalHandicapToggled){
      currentIcon = handicapIcon;
      selectedIcon = handicapSelectedIcon;
    }
    BitmapDescriptor _icon = currentIcon;
    BitmapDescriptor _selectIcon = selectedIcon;
    Marker marker;
    setState(() {
      if (currParking != null) {
        var thisParking = currParking;
        String oldAddress = thisParking.properties.address;
        Marker oldMarker = Marker(
          onTap: () {
            updateCurrentMarker(thisParking);
          },
          icon: _icon,
          markerId: MarkerId(oldAddress),
          position: LatLng(thisParking.geometry.coordinates[0][1],
              thisParking.geometry.coordinates[0][0]),
        );
        _markers[oldAddress] = oldMarker;
        print(oldMarker.position.latitude);
        print(oldMarker.position.longitude);
      }
      if(parking != null){
      marker = Marker(
        onTap: () {
          updateCurrentMarker(parking);
        },
        icon: _selectIcon,
        markerId: MarkerId(parking.properties.address),
        position: LatLng(parking.geometry.coordinates[0][1],
            parking.geometry.coordinates[0][0]),
      );
      }
      currMarker = marker;
      currParking = parking;
      if(parking != null) {
        _markers[parking.properties.address] = marker;
      }
    });
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

  Future<int> getAmountOfHighTrafficRatingsForParking(String parkingAddress) async {
    int noOfHighRatings = -1;
    await db.collection('trafficData').document(parkingAddress).collection('high').
      getDocuments().then((value) {
        noOfHighRatings = value.documents.length;
      });
    return noOfHighRatings;
  }

  Future<int> getAmountOfLowTrafficRatingsForParking(String parkingAddress) async {
    int noOfLowRatings = -1;
    await db.collection('trafficData').document(parkingAddress).collection('low').
      getDocuments().then((value) {
        noOfLowRatings = value.documents.length;
      });
    return noOfLowRatings;
  }

  //returns amount of high traffic ratings between specified hours (although cannot be an interval longer than 10 hours... :) ) (and yes, it has an incredibly long name)
  Future<int> getAmountOfHighTrafficRatingsForParkingDuringCertainHours(String parkingAddress, int fromHour, int untilHour) async {
    int noOfHighRatings = -1;
    var tempHoursList = fromHour < untilHour? hours.sublist(fromHour, untilHour) : hours.sublist(0, untilHour) + hours.sublist(fromHour, hours.length);
    await db.collection('trafficData').document(parkingAddress).collection('high').
      where("hour", whereIn: tempHoursList).getDocuments().then((value) {
        noOfHighRatings = value.documents.length;
      });
    return noOfHighRatings;
  }

  void reportTraffic(bool isTraffic, {String address}) async {
    String id = widget.userId;
    String location;

    if(address == null) {
    location =currentDestinationMarker.markerId.toString() ;
    location = location.substring(location.indexOf(":") + 1);
    location = location.substring(0, location.indexOf("}"));
    location = location.trim();
    } else { //reportTraffic is called from the feedback reminder pop up
      location = address;
      db.collection('pushNotifications').document(id).delete();
    }

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
    if(!leftFeedbackHereRecently)
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
          builder: (context) {
            Future.delayed(Duration(milliseconds: 2000), () {
              Navigator.of(context).pop(true);
            });
            return AlertDialog(
              title: Text('Tack för din feedback!'),
            );
          });

    } else {
      showDialog(
          context: context,
          builder: (context) {
            Future.delayed(Duration(milliseconds: 2000), () {
              Navigator.of(context).pop(true);
            });
            return AlertDialog(
              title: Text('Du har lämnat feedback här nyligen!'),
            );
          });
    }
  }

  Widget showMuchTrafficBtn({String address}) {
    return ButtonTheme(
      minWidth: 100.0,
      height: 50.0,
      child: RaisedButton(
        elevation: 10,
        color: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        child: new Text("Nej", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        onPressed: () {
          Navigator.of(context).pop();
          address == null?reportTraffic(true): reportTraffic(true, address: address);
        },
      ),
    );
  }

  Widget showNotMuchTrafficBtn({String address}) {
    return ButtonTheme(
      minWidth: 100.0,
      height: 50.0,
      child: new RaisedButton(
        // highlightColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        color: Colors.greenAccent,
         child: Text("Ja", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        onPressed: () {
          Navigator.of(context).pop();
          address == null?reportTraffic(false): reportTraffic(false, address: address);
        },
      ),
    );
  }

  Widget showExitArrivedAtDestinationWindow() {
    return FlatButton(
      onPressed: () {
        if(formerDestination == null)  {// pushed for the first time
          startBackgroundExecution(); //men då måste spara addressen
        } else { //closing feedback window for the second time
          formerDestination = null;
          db.collection('pushNotifications').document(widget.userId).delete();
        }
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
              Row(children: <Widget> [Text('')]), //Empty row for extra space
              Text(
                "Hittade du en ledig plats?.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16),
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

  //called when app is launched/resumed thorugh tapping a push notification
  void showArrivedEarlierAtDestinationDialog() async {
    bool show = true; //preventing the dialog from popping up when it shouldn't
    await db.collection('pushNotifications').where('user', isEqualTo: widget.userId).getDocuments().then((event) {
      if (event.documents.isNotEmpty) {
        Map<String, dynamic> documentData = event.documents.single.data;//if it is a single document
        formerDestination = documentData['parkingAddress'];
      } else {
        show = false;
      }
    }).catchError((e)=> print("error fetching data: $e"));

    if(show) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              side: BorderSide(color: Colors.black, width: 1),),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        showExitArrivedAtDestinationWindow()
                      ]
                  ),
                  Text(
                    "Du anlände tidigare vid $formerDestination.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    "Var snäll och svara om parkeringen var högtrafikerad.",
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 16),
                  ),
                  Row(children: <Widget>[Text('')]), //Empty row for extra space
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      showMuchTrafficBtn(address: formerDestination),
                      //Text("              "),
                      showNotMuchTrafficBtn(address: formerDestination),
                    ],
                  ),
                ]
            ),
          );
        },
      );
    }
  }

  String trimAddress(var marker) {
    String location = marker.markerId.toString();
    location = location.substring(location.indexOf(":") + 1);
    location = location.substring(0, location.indexOf("}"));
    location = location.trim();
    return location;
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
      'currentDestination': currentDestinationAddress
    }, initialDelay: Duration(minutes: 20));
  }

  void startRoute(LatLng destination, String destinationAddress) async{
    Workmanager.cancelAll(); //to avoid situations where users get lots of push notifications
    formerDestination = null;
    if (_markers.containsKey(destinationAddress))
      currentDestinationMarker = _markers[destinationAddress];
    currentDestination = destination;
    currentDestinationAddress = destinationAddress;
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

  void _initMarkers(double currentZoom) async {
    setState(() {
      if(_globalCarToggled){
        currentIcon = carIcon;
        selectedIcon = carSelectedIcon;
        print("car toggled");
      }else if(_globalTruckToggled){
        currentIcon = truckIcon;
        selectedIcon = truckSelectedIcon;
        print("truck toggled");
      }else if(_globalMotorcycleToggled){
        currentIcon = motorcycleIcon;
        selectedIcon = motorcycleSelectedIcon;
        print("cycle toggled");
      }else if(_globalHandicapToggled){
        currentIcon = handicapIcon;
        selectedIcon = handicapSelectedIcon;
        print("handicap toggled");
      }
    });
    _clusterManager = null;
    final List<MapMarker> markers = [];

    if (parkings != null){
      int counter = 0;
      for (final parking in parkings.features) {
        if ((parking.properties.address != '<Adress saknas>' &&
            parking.properties.vfMeter != null) ||
            !_globalCarToggled) {
          counter ++;
          final marker = MapMarker(
            onTap: () {
              updateCurrentMarker(parking);
            },
            id: parking.properties.address,
            position: LatLng(parking.geometry.coordinates[0][1],
                parking.geometry.coordinates[0][0]),
            icon: currentIcon,
          );
          markers.add(marker);
          parkMark[parking.properties.address] = parking;
        }
      }
      print('loaded ' + counter.toString() + ' to screen');
    }

    _clusterManager = await MapHelper.initClusterManager(markers, 0, 15);
    await _updateMarkers(currentZoom);
  }

  Future<void> _updateMarkers([double updatedZoom]) async {
    if(_clusterManager == null || updatedZoom == _currentZoom) return;

    if(updatedZoom != null){
      _currentZoom = updatedZoom;
      print(updatedZoom);
      print(_currentZoom);
    }

    final updatedMarkers = await MapHelper.getClusterMarkers(
      _clusterManager,
      _currentZoom,
      _clusterColor,
      _clusterTextColor,
      80,
    );
    _markers.clear();
    updatePinOnMap();
    for(var v in updatedMarkers){
      _markers[v.markerId.toString()] = v;
    }
    setState(() {
      _isLoading = false;
    });
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
              _globalCarToggled, _globalTruckToggled, _globalMotorcycleToggled, _globalHandicapToggled),
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          MotorcycleIconButton(),
                          HandicapIconButton(),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
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
        _globalCarToggled = ic.carToggled;
        _globalTruckToggled = ic.truckToggled;
        _globalMotorcycleToggled = ic.motorcycleToggled;
        _globalHandicapToggled = ic.handicapToggled;
      }
      _markers.clear();
      setState(() {
        newToggle = true;
      });
      _newMarkers(cameraPosition);
    });
  }

  Widget showHandicapIconButton() {
    return StatefulBuilder(builder: (context, setState) {
      return Align(
        alignment: Alignment.centerLeft,
        child: HandicapIconButton(),
        );
    });
  }

  Widget showCloseButton(BuildContext context) {
    var iconInfo = Provider.of<IconInfo>(context);
    return StatefulBuilder(builder: (context, setState) {
      return OutlineButton(
        borderSide: BorderSide(color: Colors.grey, width: 2),
        onPressed: () => {
          Navigator.pop(context, iconInfo),
        },
        child: Text("Stäng", style: TextStyle(fontSize: 17)),
      );
    });
  }
}

class HandicapIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var iconInfo = Provider.of<IconInfo>(context);
    return IconButton(
      iconSize: 42,
    icon: Icon(
    Icons.accessible,
    color: iconInfo.handicapToggled ? Colors.orangeAccent : Colors.grey,
    ),
    onPressed: () {
        iconInfo.handicap = !iconInfo.handicapToggled;
        if(iconInfo.handicapToggled){
          iconInfo.motorcycle = false;
          iconInfo.truck = false;
          iconInfo.car = false;
        }
    },
    );
  }
}

class CarIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var iconInfo = Provider.of<IconInfo>(context);
    return IconButton(
        iconSize: 42,
        icon: Icon(
          Icons.directions_car,
          color: iconInfo.carToggled ? Colors.orangeAccent : Colors.grey,
        ),
        onPressed: () {
          iconInfo.car = !iconInfo.carToggled;
          if (iconInfo.carToggled) {
            iconInfo.motorcycle = false;
            iconInfo.truck = false;
            iconInfo.handicap = false;
          }
        });
  }
}

class TruckIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var iconInfo = Provider.of<IconInfo>(context);
    return IconButton(
        iconSize: 42,
        icon: Icon(
          MdiIcons.truck,
          color: iconInfo.truckToggled ? Colors.orangeAccent : Colors.grey,
        ),
        onPressed: () {
          iconInfo.truck = !iconInfo.truckToggled;
          if (iconInfo.truckToggled) {
            iconInfo.car = false;
            iconInfo.motorcycle = false;
            iconInfo.handicap = false;
          }
        }
    );
  }
}

class MotorcycleIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var iconInfo = Provider.of<IconInfo>(context);
    return IconButton(
        iconSize: 42,
        icon: Icon(
          Icons.motorcycle,
          color: iconInfo.motorcycleToggled ? Colors.orangeAccent : Colors.grey,
        ),
        onPressed: () {
          iconInfo.motorcycle = !iconInfo.motorcycleToggled;
          if (iconInfo.motorcycleToggled) {
            iconInfo.car = false;
            iconInfo.truck = false;
            iconInfo.handicap = false;
          }
        });
  }
}

//                    parking.properties.fid != null &&
//                    parking.properties.featureObjectId != null &&
//                    parking.properties.featureVersionId != null &&
//                    parking.properties.extentNo != null &&
//                    parking.properties.validFrom != null &&
//                    parking.properties.startTime != null &&
//                    parking.properties.endTime != null &&
//                    parking.properties.startWeekday != null &&
//                    parking.properties.maxHours != null &&
//                    parking.properties.citation != null &&
//                    parking.properties.streetName != null &&
//                    parking.properties.parkingDistrict != null &&
//                    parking.properties.vfPlatsTyp != null &&
//                    parking.properties.otherInfo != null &&
//                    parking.properties.rdtUrl != null &&
//parking.properties.vfMeter != null ||
//                    parking.geometry.type != null &&
//                    parking.geometryName != null &&
//                    parking.type != null &&
//                    parking.properties.cityDistrict != null ||
//!_globalCarToggled
//) {
/*
Properties:
                  int fid;
                  int featureObjectId;
                  int featureVersionId;
                  int extentNo;
                  DateTime validFrom;
                  int startTime;
                  int endTime;
                  String startWeekday;
                  int maxHours;
                  String citation;
                  String streetName;
                  String cityDistrict;
                  String parkingDistrict;
                  String address;
                  String vfPlatsTyp;
                  String otherInfo;
                  String rdtUrl;
                  int vfMeter;
*/