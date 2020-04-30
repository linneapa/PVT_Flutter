
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Close2MePage extends StatefulWidget{
  @override
  _Close2MePageState createState() => _Close2MePageState();
}

class _Close2MePageState extends State<Close2MePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MAP")
      ,), 
      body: GoogleMap(initialCameraPosition: CameraPosition(
        target: LatLng(37.77483, -122.41942),
        zoom: 12,
      )
      ,)
    ,);
  }
}
