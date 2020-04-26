import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  _SearchPageState createState() => _SearchPageState();
}

  class _SearchPageState extends State<SearchPage> {
  var currentSelectedVehicle = 'Car';
  var currentSelectedProximity = 'Very Close';
  var currentSelectedPriceRange = '0 - 50 kr';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.greenAccent,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white, size: 40),
            tooltip: "Settings",
            onPressed: () {
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 45, right: 45),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            Text("Vehicle:"),
            new DropdownButton<String>(
              items: <String>['Car', 'Motorcycle', 'Truck', 'Bike'].map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (String newSelectedValue) {
                setState(() {
                  this.currentSelectedVehicle = newSelectedValue;
                });
              },
              value: currentSelectedVehicle,
            ),

            SizedBox(height: 20),

            Text("Address:"),
            TextField(),

            SizedBox(height: 20),

            Text("Set Proximity:"),

            new DropdownButton<String>(
              // items are currently just placeholders
              items: <String>['Very Close', 'Kinda close', 'Not so close', 'So far away'].map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (String newSelectedValue) {
                setState(() {
                  this.currentSelectedProximity = newSelectedValue;
                });
              },
              value: currentSelectedProximity,
            ),

            SizedBox(height: 20),

            Text("Price range:"),
            new DropdownButton<String>(
              // items are currently just placeholders
              items: <String>['0 - 50 kr', '51 - 100 kr', '100 - 150 kr', '> 200 kr'].map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (String newSelectedValue) {
                setState(() {
                  this.currentSelectedPriceRange = newSelectedValue;
                });
              },
              value: currentSelectedPriceRange,
            ),
          ],
        ),
      ),
    );
  }
}
