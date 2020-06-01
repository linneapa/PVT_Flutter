import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'ParkingSpace.dart';

class Services {
  static Future<Parkering> fetchParkering(DocumentSnapshot doc, CameraPosition position, bool car, bool truck, bool motorcycle, bool handicaped) async {
    /// https://openparking.stockholm.se/LTF-Tolken/v1/{föreskrift}/{operation}?apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97
    ///Föreskrift: servicedagar, ptillaten, pbuss, plastbil, pmotorcykel, prorelsegindrad
    ///Operation: all, weekday, area, street, within, untilNextWeekday
    ///Parameters: apiKey, MaxFeatures, outputFormat, callback

    String url;
    String firstPart;
    int radius;
    if (car) {
      firstPart = 'https://openparking.stockholm.se/LTF-Tolken/v1/ptillaten';
    } else if (truck) {
      firstPart = 'https://openparking.stockholm.se/LTF-Tolken/v1/plastbil';
    } else if (motorcycle) {
      firstPart = 'https://openparking.stockholm.se/LTF-Tolken/v1/pmotorcykel';
    } else if (handicaped) {
      firstPart = 'https://openparking.stockholm.se/LTF-Tolken/v1/prorelsehindrad';
    }
    if (doc != null) {
      url =
          'https://openparking.stockholm.se/LTF-Tolken/v1/ptillaten/within?radius=1&lat=' +
              doc['coordinatesX'].toString() +
              '&lng=' + doc['coordinatesY'].toString() +
              '&outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97';
      print(url);
    } else if (position != null){
      String operation = '/within?radius=';
      radius = (21 - position.zoom.toInt()) * 300;
      url = firstPart + operation + radius.toString() + '&lat=' +
          position.target.latitude.toString() + '&lng=' +
          position.target.longitude.toString() +
          '&outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97';
    } else{
      String secondPart = '/all?&outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97';
      url = firstPart + secondPart;
    }


    if (url == null){
        return null;
    }
    final response = await http.get(url);
    Map<String, dynamic> JSON = json.decode(response.body);
    if (JSON['totalFeatures'] == 0){
      return null;
    }
    if (response.statusCode == 200) {
      return Parkering.fromJson(JSON);
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
Future<ParkingPost> fetchParkingPost(http.Client client, DocumentSnapshot doc, CameraPosition position, bool car, bool truck, bool motorcycle, bool handicaped) async {

  String url;
  String firstPart = '';
  int radius;
  if (car) {
    firstPart = 'https://openparking.stockholm.se/LTF-Tolken/v1/ptillaten';
  } else if (truck) {
    firstPart = 'https://openparking.stockholm.se/LTF-Tolken/v1/plastbil';
  } else if (motorcycle) {
    firstPart = 'https://openparking.stockholm.se/LTF-Tolken/v1/pmotorcykel';
  } else if (handicaped) {
    firstPart = 'https://openparking.stockholm.se/LTF-Tolken/v1/prorelsehindrad';
  }
  if (doc != null) {
    url =
        'https://openparking.stockholm.se/LTF-Tolken/v1/ptillaten/within?radius=1&lat=' +
            doc['coordinatesX'].toString() +
            '&lng=' + doc['coordinatesY'].toString() +
            '&outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97';
    print(url);
  } else if (position != null){
    String operation = '/within?radius=';
    radius = (21 - position.zoom.toInt()) * 300;
    url = firstPart + operation + radius.toString() + '&lat=' +
        position.target.latitude.toString() + '&lng=' +
        position.target.longitude.toString() +
        '&outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97';
  } else if(firstPart != null){
    String secondPart = '/all?&outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97';
    url = firstPart + secondPart;
  }


  if (url == null){
    return null;
  }
  final response = await client.get(url);
  Map<String, dynamic> JSON = json.decode(response.body);
  if (JSON['totalFeatures'] == 0){
    return null;
  }
  if (response.statusCode == 200) {
    return ParkingPost.fromJson(JSON);
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}