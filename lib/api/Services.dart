import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'ParkingSpace.dart';

class Services {
  static Future<Parkering> fetchParkering(DocumentSnapshot doc, bool car, bool truck, bool motorcycle, bool handicaped) async {
    // https://openparking.stockholm.se/LTF-Tolken/v1/{föreskrift}/{operation}?apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97

    /*
      Föreskrift: servicedagar, ptillaten, pbuss, plastbil, pmotorcykel, prorelsegindrad
      Operation: all, weekday, area, street, within, untilNextWeekday
      Parameters: apiKey, MaxFeatures, outputFormat, callback
       */

    String url;
    if (doc != null){
//      String lat = marker.toString().split("LatLng")[1].split(',')[0].replaceAll("(", "");
//      String lng = marker.toString().split("LatLng")[1].split(',')[1].replaceAll(")", "").trim();
//      url = 'https://openparking.stockholm.se/LTF-Tolken/v1/ptillaten/within?radius=1&lat=' + lat + '&lng=' + lng + '&outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97';
      url = 'https://openparking.stockholm.se/LTF-Tolken/v1/ptillaten/within?radius=1&lat=' + doc['coordinatesX'].toString() + '&lng=' + doc['coordinatesY'].toString() + '&outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97';
      print(url);
    } else if (car) {
      url = 'https://openparking.stockholm.se/LTF-Tolken/v1/ptillaten/all?maxFeatures=100&outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97';
      print(url);
    } else if(truck) {
      url = 'https://openparking.stockholm.se/LTF-Tolken/v1/plastbil/all?outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97';
      print(url);
    } else if (motorcycle){
      url = 'https://openparking.stockholm.se/LTF-Tolken/v1/pmotorcykel/all?maxFeatures=100&outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97';
    } else if (handicaped){
      url = 'https://openparking.stockholm.se/LTF-Tolken/v1/prorelsehindrad/all?&maxFeatures=100&outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97';
    } else {
      return null;
    }
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return Parkering.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load parkering');
    }
  }
}


// for testing
class ParkingPost {
  dynamic data;
  ParkingPost.fromJson(this.data);
}
// for testing
Future<ParkingPost> fetchParkingPost(http.Client client, bool car, bool lastbil, bool motorcyckel, bool handicaped) async {

  String url;
  if (car) {
    url = 'https://jsonplaceholder.typicode.com/posts/1';
  } else if(lastbil) {
    url = 'https://jsonplaceholder.typicode.com/posts/1';
  } else if (motorcyckel){
    url = 'https://jsonplaceholder.typicode.com/posts/1';
  } else if (handicaped){
    url = 'https://jsonplaceholder.typicode.com/posts/1';
  } else {
    return null;
    //throw Exception('No vehicle');
  }
  final response = await client.get(url);
  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    return ParkingPost.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}