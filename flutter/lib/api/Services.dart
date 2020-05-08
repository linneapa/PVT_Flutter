import 'dart:convert';

import 'package:http/http.dart' as http;
import 'ParkingSpace.dart';

class Services {
  static Future<Parkering> fetchParkering() async {
    // :TODO Here must come the filter logic (avstånd, vehicle type, address n shit)
    final response = await http.get(
        'https://openparking.stockholm.se/LTF-Tolken/v1/pbuss/within?radius=100&lat=59.32784&lng=18.05306&outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Parkering.fromJson(json.decode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load parkering');
    }
  }
}
