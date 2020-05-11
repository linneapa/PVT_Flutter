import 'dart:convert';

import 'package:http/http.dart' as http;
import 'ParkingSpace.dart';

class Services {
  static Future<Parkering> fetchParkering() async {
    // :TODO Here must come the filter logic (avstånd, vehicle type, address n shit)
    final response = await http.get(
      // https://openparking.stockholm.se/LTF-Tolken/v1/{föreskrift}/{operation}?apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97

      /*
      Föreskrift: servicedagar, ptillaten, pbuss, plastbil, pmotorcykel, prorelsegindrad
      Operation: all, weekday, area, street, within, untilNextWeekday
      Parameters: apiKey, MaxFeatures, outputFormat, callback
       */
        'https://openparking.stockholm.se/LTF-Tolken/v1/servicedagar/weekday/m%C3%A5ndag?outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97');

    if (response.statusCode == 200) {
      return Parkering.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load parkering');
    }
  }
}
