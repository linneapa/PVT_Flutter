import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Close2MePage extends StatefulWidget{
  @override
  _Close2MePageState createState() => _Close2MePageState();
}

class _Close2MePageState extends State<Close2MePage> {

  static final CameraPosition initPosition = CameraPosition(
  target: LatLng(37.77483, -122.41942),
  zoom: 12,
  );

  Location _myLocation = Location();
  GoogleMapController _controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<CircleId,Circle> circles = <CircleId, Circle>{};
  BitmapDescriptor arrowIcon;
  LatLng initLocation;

  @override
  void initState() {
    super.initState();
//    BitmapDescriptor.fromAssetImage(ImageConfiguration(
//        devicePixelRatio: 2.5), 'assets/direction-arrow.png').then((onValue){
//          arrowIcon = onValue;
//    });
    setInitLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MAP")
      ,), 
      body: GoogleMap(
        initialCameraPosition: initPosition,
        markers: Set<Marker>.of(markers.values),
        circles: Set<Circle>.of(circles.values),
        onMapCreated: (GoogleMapController controller){
          _controller = controller;
          setState((){
            markers[MarkerId('PhoneLocationMarker')]=Marker(
              markerId: MarkerId('PhoneLocationMarker'),
              position: initLocation);
//              , icon: arrowIcon );
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.my_location),
        onPressed: () {
          showCurrentLocation();
        }
      ), floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void showCurrentLocation() async{
    LocationData newLocation = await _myLocation.getLocation();
    _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
        bearing: 0,
        target: LatLng(newLocation.latitude, newLocation.longitude),
        tilt: 0,
        zoom: 18)));
  }
  void setInitLocation()async {
    initLocation = await getCurrentLocation();
}

  Future<LatLng> getCurrentLocation() async{
    LocationData newLocation = await _myLocation.getLocation();
    return LatLng(newLocation.latitude, newLocation.longitude);
  }
}
