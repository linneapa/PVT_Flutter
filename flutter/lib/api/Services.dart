import 'dart:convert';

import 'package:http/http.dart' as http;
import 'ParkingSpace.dart';

class Services {
  static Future<Parkering> fetchParkering(bool car, bool lastbil, bool motorcyckel, bool handicaped) async {
    // https://openparking.stockholm.se/LTF-Tolken/v1/{föreskrift}/{operation}?apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97

    /*
      Föreskrift: servicedagar, ptillaten, pbuss, plastbil, pmotorcykel, prorelsegindrad
      Operation: all, weekday, area, street, within, untilNextWeekday
      Parameters: apiKey, MaxFeatures, outputFormat, callback
       */
    String url;
    if (car) {
      url = 'https://openparking.stockholm.se/LTF-Tolken/v1/ptillaten/all?maxFeatures=100&outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97';
    } else if(lastbil) {
      url = 'https://openparking.stockholm.se/LTF-Tolken/v1/plastbil/all?outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97';
    } else if (motorcyckel){
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
