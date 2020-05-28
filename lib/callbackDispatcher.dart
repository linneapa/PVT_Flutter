import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:ezsgame/pages/map_page.dart';
import 'dart:math' as Math;
import 'package:cloud_firestore/cloud_firestore.dart';
// const myTask = "syncWithTheBackEnd";

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {

      print("\n\n888888888888888888888888888888888888888888888888888888888888888\n\n");

        Geolocator geolocator = Geolocator();
        double currDestLat = inputData['lat'];
        double currDestLong = inputData['long'];
        String uid = inputData['uid'];
        int counter = 0;
    
    // (await Firestore.instance
    //     .collection('userData')
    //     .document()
    //     .collection('desintation').document("destination").get()).data["destination"];

        Position currentPosition = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, locationPermissionLevel: GeolocationPermission.locationAlways);
        print("\n\n\n\n\n\n\n$currentPosition");
        print(currentPosition.latitude);
        print(currDestLat);
        print(currDestLong);
                print("\n\n\n\n\n\n\n");


    // _getCurrentLocation();
    while(counter++ < 5000) {
      print(counter);
    }
    // if(distanceBetweenPoints(currentPosition.latitude, currentPosition.longitude, currDestLat, currDestLong) > 20) {
    //     // currentPosition = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, locationPermissionLevel: GeolocationPermission.locationAlways);    
      await Firestore.instance.collection("orders")
        .document("hello")
        .setData({
        'seller': uid,
        'description': 'success :)'
       });


      //unsubscribe
              print("succedddded");

    

    //skicka till db
    print("\n\n\n\n\nooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo\n\nooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo\n\nooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo\n\nooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo\n\nooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo\n\nooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo\n\nooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo\n\nooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo\n\nooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo\n\nooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo\n\nooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo\n\nooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo\n\n\n\n "); //simpleTask will be emitted here.
    return Future.value(true);
  });
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