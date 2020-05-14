import 'dart:async';
import 'package:ezsgame/api/Services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'IconInfo.dart';
import 'package:flutter/foundation.dart';
import 'settings.dart';
import 'favorites.dart';
import 'package:location/location.dart';
import 'package:flutter/widgets.dart';
import 'SizeConfig.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();

  MapPage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
}

class _MapPageState extends State<MapPage> with ChangeNotifier {

  bool handicapToggled = false;
  var _globalCarToggled = true;
  var _globalTruckToggled = false;
  var _globalMotorcycleToggled = false;
  bool _filterSwitched = false;
  var _distanceValue = 0.0;
  var _costValue = 0.0;

  static final CameraPosition initPosition = CameraPosition(
    target: LatLng(59.3293, 18.0686),
    zoom: 12,
  );
  Location location = Location();
  LocationData _myLocation;
  GoogleMapController _controller;
  StreamSubscription<LocationData> _locationSubscription;
  final Map<String, Marker> _markers = {};
  final Map<String, Circle> circles = {};
  BitmapDescriptor arrowIcon;
  LatLng initLocation = LatLng(59.3293, 18.0686);
  String _error;

  // this will hold the generated polylines
  Set<Polyline> _polylines = {};
  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];
  // this is the key object - the PolylinePoints
  // which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();


 LatLng testDestinationForDisplayingRoute = LatLng(59.368585, 18.050156);


  @override
  void initState() {
    super.initState();
//    BitmapDescriptor.fromAssetImage(ImageConfiguration(
//        devicePixelRatio: 2.5), 'assets/direction-arrow.png').then((onValue){
//          arrowIcon = onValue;
//    });
    setInitLocation();
  }

  Future navigateToCurrentPage(context) async {}

  Future navigateToFavoritesPage(context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
            new FavouritesPage(
              auth: widget.auth,
              logoutCallback: widget.logoutCallback,
            )));
  }

  Future navigateToSettingsPage(context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
            new SettingsPage(
              auth: widget.auth,
              logoutCallback: widget.logoutCallback,
            )));
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
             if(_myLocation != currentLocation)
               changed = true;
            _myLocation = currentLocation;
            updatePinOnMap();
             if(changed)
                setPolylines(testDestinationForDisplayingRoute);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    _listenLocation();
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: showSearchTextField(),
        actions: <Widget>[
          showFilterButton(),
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Container(
              // Google maps container with a set size below.
              height: SizeConfig.blockSizeVertical * 75,
              child: Stack(
                // Stack used to allow myLocationButton on top of google maps.
                children: <Widget>[
                  showGoogleMaps(),
                  showMyLocationButton(),
                ],
              ),
            ),
            Expanded(
              // Code for the bottom navigation bar below.
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 1),
                  showFavoritesNavigationButton(),
                  showMapNavigationButton(),
                  showSettingsNavigationButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showSearchTextField() {
    return TextField(
      decoration: new InputDecoration(
        hintText: 'Sök gata, adress, etc.',
        border: new OutlineInputBorder(),
        prefixIcon: IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget showFilterButton() {
    return IconButton(
      icon: Icon(
        MdiIcons.filterMenu,
        color: _filterSwitched ? Colors.orangeAccent : Colors.grey,
      ),
      onPressed: () {
        createDialog(context);
        showGoogleMaps();
        // do something
      },
    );
  }


  Future<void> _onMapCreated(GoogleMapController controller) async {
    var parkings = await Services.fetchParkering(_globalCarToggled, _globalTruckToggled, _globalMotorcycleToggled, handicapToggled);
    _controller = controller;
    setState(() {
      _markers.clear();
      for (final parking in parkings.features) {
        final marker = Marker(
            markerId: MarkerId(parking.properties.address),
            position: LatLng(parking.geometry.coordinates[0][1],
                parking.geometry.coordinates[0][0]),
            infoWindow: InfoWindow(
              title: parking.properties.cityDistrict,
              snippet: parking.properties.address,
            )
        );
        _markers[parking.properties.cityDistrict] = marker;
      }
      updatePinOnMap();
    });
  }

  Widget showGoogleMaps() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      polylines: _polylines,
      initialCameraPosition: CameraPosition(
        target: const LatLng(59.3293, 18.0686),
        zoom: 12,
      ),
      markers: _markers.values.toSet(),
    );
  }

  setPolylines(LatLng destination) async {
   List<PointLatLng> result = (await
      polylinePoints?.getRouteBetweenCoordinates(
         "AIzaSyBLNOKl2W5s0vuY0aZ-ll_PNoeldgko12w",
         PointLatLng(_myLocation.latitude, 
         _myLocation.longitude),
         PointLatLng(destination.latitude, 
         destination.longitude))).points;
   if(result.isNotEmpty){
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      polylineCoordinates.clear();
      result.forEach((PointLatLng point){
         polylineCoordinates.add(
            LatLng(point.latitude, point.longitude));
      });
   }
   setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      Polyline polyline = Polyline(
         polylineId: PolylineId("poly"),
         color: Color.fromARGB(255, 40, 122, 198),
         points: polylineCoordinates
      );
 
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

  Widget showFavoritesNavigationButton() {
    return FlatButton(
        onPressed: () =>
        {
          navigateToFavoritesPage(context),
        },
        child: Column(
          children: <Widget>[
            Icon(Icons.favorite, size: 45, color: Colors.grey),
            Text("Favoriter",
                style: TextStyle(
                  fontSize: 13,
                ))
          ],
        ));
  }

  Widget showMapNavigationButton() {
    return FlatButton(
        onPressed: () =>
        {
          // This button does nothing yet...
        },
        child: Column(
          children: <Widget>[
            Icon(Icons.map, size: 45, color: Colors.orangeAccent),
            Text("Karta",
                style: TextStyle(
                  fontSize: 13,
                ))
          ],
        ));
  }

  Widget showSettingsNavigationButton() {
    return FlatButton(
        onPressed: () =>
        {
          navigateToSettingsPage(context),
        },
        child: Column(
          children: <Widget>[
            Icon(Icons.settings, size: 45, color: Colors.grey),
            Text("Inställningar",
                style: TextStyle(
                  fontSize: 13,
                ))
          ],
        ));
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
        position: LatLng(_myLocation.latitude, _myLocation.longitude));
  }

  createDialog(BuildContext context) {
    // The following code is for the filter popup page.
    showDialog(
      context: context,
      builder: (context) {
        return ChangeNotifierProvider(
          create: (context) => IconInfo(_globalCarToggled, _globalTruckToggled, _globalMotorcycleToggled),
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                content: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Filter"),
                          showSwitchButton(),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          CarIconButton(),
                          TruckIconButton(),
                          MotorcycleIconButton()
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text("Avstånd från destination:"),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Kort"),
                                Expanded(child: showDistanceSlider()),
                                Text("Långt"),
                              ]),
                          Text("Prisklass:"),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Låg"),
                                Expanded(child: showCostSlider()),
                                Text("Hög"),
                              ]),
                        ],
                      ),
                      showHandicapIconButton(),
                    ],
                  ),
                ),
                actions: <Widget>[
                  showCancelButton(context),
                  showOkButton(context),
                ],
              );
            },
          ),
        );
      },
    ).then((val) { // retrieve and update the state of the icons
      IconInfo ic = val;
      if (ic != null) {
        _globalMotorcycleToggled = ic.motorcycleToggled;
        _globalTruckToggled = ic.truckToggled;
        _globalCarToggled = ic.carToggled;
      }
    });
  }

  Widget showSwitchButton() {
    return StatefulBuilder(builder: (context, setState) {
      return Align(
        alignment: Alignment.centerRight,
        child: Switch(
          value: _filterSwitched,
          onChanged: (value) {
            setState(() {
              _filterSwitched = value;
            });
          },
          activeTrackColor: Colors.orangeAccent,
          activeColor: Colors.orange,
        ),
      );
    });
  }

  Widget showDistanceSlider() {
    return StatefulBuilder(builder: (context, setState) {
      return SliderTheme(
        data: SliderThemeData(
          thumbColor: Colors.orangeAccent,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
          inactiveTickMarkColor: Colors.black,
          activeTickMarkColor: Colors.black,
          activeTrackColor: Colors.orangeAccent,
          inactiveTrackColor: Colors.grey,
        ),
        child: Slider(
          min: 0,
          max: 100,
          value: _distanceValue,
          divisions: 2,
          onChanged: (value) {
            setState(() {
              _distanceValue = value;
            });
          },
        ),
      );
    });
  }

  Widget showCostSlider() {
    return StatefulBuilder(builder: (context, setState) {
      return Center(
        child: SliderTheme(
          data: SliderThemeData(
            thumbColor: Colors.orangeAccent,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
            inactiveTickMarkColor: Colors.black,
            activeTickMarkColor: Colors.black,
            activeTrackColor: Colors.orangeAccent,
            inactiveTrackColor: Colors.grey,
          ),
          child: Slider(
            min: 0,
            max: 100,
            value: _costValue,
            divisions: 2,
            onChanged: (value) {
              setState(() {
                _costValue = value;
              });
            },
          ),
        ),
      );
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

  Widget showOkButton(BuildContext context) {
    var iconInfo = Provider.of<IconInfo>(context);
    return StatefulBuilder(builder: (context, setState) {
      return FlatButton(
        onPressed: () => {
          _onMapCreated(_controller),
          Navigator.pop(context, iconInfo),
        },
        child: Text("Klar"),
      );
    });
  }

  Widget showCancelButton(BuildContext context) {
    var iconInfo = Provider.of<IconInfo>(context);
    return StatefulBuilder(builder: (context, setState) {
      return FlatButton(
        onPressed: () => {
          Navigator.pop(context, iconInfo),
          _onMapCreated(_controller),
        },
        child: Text("Avbryt"),
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
          if (truckValue)
            iconInfo.truck = !truckValue;

          bool motorcycleValue = iconInfo.motorcycleToggled;
          if (motorcycleValue)
            iconInfo.motorcycle = !motorcycleValue;
        }
    );
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
          if (carValue)
            iconInfo.car = !carValue;

          bool truckValue = iconInfo.truckToggled;
          if (truckValue)
            iconInfo.truck = !truckValue;
        }
    );
  }
}

