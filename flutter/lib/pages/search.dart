
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SearchPage extends StatefulWidget {
  _SearchPageState createState() => _SearchPageState();
}

  class _SearchPageState extends State<SearchPage> {
  var currentSelectedVehicle = 'Car';
  var currentSelectedProximity = 'Very Close';
  var currentSelectedPriceRange = '0 - 50 kr';
  bool handicapToggled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Search", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.greenAccent,
        actions: <Widget>[
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
              items: [
                DropdownMenuItem(
                  value: "Car",
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(Icons.directions_car),
                      SizedBox(width: 10),
                      Text(
                        "Car",
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: "Motorcycle",
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(Icons.motorcycle),
                      SizedBox(width: 10),
                      Text(
                        "Motorcycle",
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: "2",
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(MdiIcons.truck),
                      SizedBox(width: 10),
                      Text(
                        "Truck",
                      ),
                    ],
                  ),
                ),
              ],


              onChanged: (String newSelectedValue) {
                setState(() {
                  this.currentSelectedVehicle = newSelectedValue;
                });
              },
              value: currentSelectedVehicle,
            ),

            SizedBox(height: 20),

            Text("Address:"),
            TextField(
              decoration: new InputDecoration(
                border: new OutlineInputBorder(
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),

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

            SizedBox(height: 15),

            Flexible(
              child: Row(
                children: <Widget>[

                  SizedBox(width: 40),

                  SizedBox(
                      width: 50,
                      height: 50,
                      child: RaisedButton(// Handicap toggle button
                        padding: const EdgeInsets.all(16),
                        onPressed: () => setState(() => handicapToggled = !handicapToggled),
                        color: handicapToggled ? Colors.lightBlueAccent : Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(7)
                        ),
                        child: Icon(Icons.accessible, color: Colors.black, size: 25),
                      )
                  ),

                  SizedBox(width: 15),

                  RaisedButton( // Find a parking button
                      padding: const EdgeInsets.all(16),
                      onPressed: () => {},
                      color: Colors.greenAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(7)
                      ),
                      child: Text("Find a parking!")
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}

