import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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

class _MapPageState extends State<MapPage> {
  bool handicapToggled = false;
  bool carToggled = true;
  bool truckToggled = false;
  bool motorcycleToggled = false;
  bool _filterSwitched = false;
  var _distanceValue = 0.0;
  var _costValue = 0.0;

  static final CameraPosition initPosition = CameraPosition(
    target: LatLng(37.77483, -122.41942),
    zoom: 12,
  );
  Location location = Location();
  LocationData _myLocation;
  GoogleMapController _controller;
  StreamSubscription<LocationData> _locationSubscription;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<CircleId, Circle> circles = <CircleId, Circle>{};
  BitmapDescriptor arrowIcon;
  LatLng initLocation = LatLng(59.3293, 18.0686);
  String _error;

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
            builder: (context) => new FavouritesPage(
                  auth: widget.auth,
                  logoutCallback: widget.logoutCallback,
                )));
  }

  Future navigateToSettingsPage(context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new SettingsPage(
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
        _myLocation = currentLocation;
        updatePinOnMap();
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
                children: <Widget>[
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 5),
                  showFavoritesNavigationButton(),
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 7),
                  showMapNavigationButton(),
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 7),
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
        // do something
      },
    );
  }

  Widget showGoogleMaps() {
    return GoogleMap(
      initialCameraPosition: initPosition,
      markers: Set<Marker>.of(markers.values),
      circles: Set<Circle>.of(circles.values),
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
        setState(() {
          markers[MarkerId('PhoneLocationMarker')] = Marker(
              markerId: MarkerId('PhoneLocationMarker'),
              position: LatLng(_myLocation.latitude, _myLocation.longitude));
          //, icon: arrowIcon );
        });
      },
    );
  }

  Widget showMyLocationButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FloatingActionButton(
          child: Icon(Icons.my_location, color: Colors.black),
          backgroundColor: Color.fromRGBO(160, 160, 160, 1.0),
          onPressed: () {
            showCurrentLocation();
          }),
    );
  }

  Widget showFavoritesNavigationButton() {
    return FlatButton(
        onPressed: () => {
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
        onPressed: () => {
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
        onPressed: () => {
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

  void showCurrentLocation() async {
    _myLocation = await location.getLocation();
    _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
        bearing: 0,
        target: LatLng(_myLocation.latitude, _myLocation.longitude),
        tilt: 0,
        zoom: 18)));
  }

  void setInitLocation() async {
    initLocation = await getCurrentLocation();
  }

  Future<LatLng> getCurrentLocation() async {
    _myLocation = await location.getLocation();
    return LatLng(_myLocation.latitude, _myLocation.longitude);
  }

  void updatePinOnMap() async {
    markers[MarkerId('PhoneLocationMarker')] = Marker(
        markerId: MarkerId('PhoneLocationMarker'),
        position: LatLng(_myLocation.latitude, _myLocation.longitude));
  }

  createDialog(BuildContext context) {
    // The following code is for the filter popup page.
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Filter"),
                        showSwitchButton(),
                      ],
                    ),
                    Row(
                      // Code for vehicle icons below.
                      children: <Widget>[
                        showCarIconButton(),
                        showTruckIconButton(),
                        showMotorcycleIconButton(),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        SizedBox(
                          height: SizeConfig.blockSizeVertical * 5,
                        ),
                        Text("Avstånd från dest.(20 m)"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                          Text("Lågt"),
                          Expanded(child: showDistanceSlider()),
                          Text("Högt"),
                        ]),
                        Text("Prisklass (<15 kr)"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                          Text("Lågt"),
                          Expanded(child: showDistanceSlider()),
                          Text("Högt"),
                        ]),
                      ],
                    ),
                    showHandicapIconButton(),
                  ],
                ),
              ),
              actions: <Widget>[
                showCancelButton(),
                showOkButton(),
              ],
            );
          },
        );
      },
    );
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

  Widget showCarIconButton() {
    return StatefulBuilder(builder: (context, setState) {
      return IconButton(
        iconSize: 50,
        icon: Icon(
          Icons.directions_car,
          color: carToggled ? Colors.orangeAccent : Colors.grey,
        ),
        onPressed: () => setState(() => carToggled = !carToggled),
      );
    });
  }

  Widget showTruckIconButton() {
    return StatefulBuilder(builder: (context, setState) {
      return IconButton(
        iconSize: 50,
        icon: Icon(
          MdiIcons.truck,
          color: truckToggled ? Colors.orangeAccent : Colors.grey,
        ),
        onPressed: () => setState(() => truckToggled = !truckToggled),
      );
    });
  }

  Widget showMotorcycleIconButton() {
    return StatefulBuilder(builder: (context, setState) {
      return IconButton(
        iconSize: 50,
        icon: Icon(
          Icons.motorcycle,
          color: motorcycleToggled ? Colors.orangeAccent : Colors.grey,
        ),
        onPressed: () => setState(() => motorcycleToggled = !motorcycleToggled),
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

  Widget showCancelButton() {
    return FlatButton(
      onPressed: () => Navigator.pop(context),
      child: Text("Avbryt"),
    );
  }

  Widget showOkButton() {
    return FlatButton(
      onPressed: () => {
        Navigator.pop(context),
      },
      child: Text("Klar"),
    );
  }
}
