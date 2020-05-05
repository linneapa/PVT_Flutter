import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'settings.dart';
import 'favorites.dart';

class MapPage extends StatefulWidget{
  @override
  _MapPageState createState() => _MapPageState();

  MapPage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
}

class _MapPageState extends State<MapPage> {

  Future navigateToSettingsPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => new SettingsPage(
      auth: widget.auth,
      logoutCallback: widget.logoutCallback,
    )));

  }

  Future navigateToFavoritesPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => new FavouritesPage()));
  }

  Future navigateToCurrentPage(context) async {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => new MapPage()));
  }

  bool handicapToggled = false;
  bool carToggled = true;
  bool truckToggled = false;
  bool motorcycleToggled = false;
  bool _filterSwitched = false;
  var _distanceValue = 0.0;
  var _costValue = 0.0;

  createDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Container(
                child: Column(
                  children: <Widget>[
                    Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Filter"),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Switch(
                            value: _filterSwitched,
                            onChanged: (value) {
                              setState(() {
                                _filterSwitched = value;
                              });
                            },
                            activeTrackColor: Colors.orangeAccent,
                            activeColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        IconButton(
                          iconSize: 50,
                          icon: Icon(
                            Icons.directions_car,
                            color: carToggled ? Colors.orangeAccent : Colors.grey,
                          ),
                          onPressed: () => setState(() => carToggled = !carToggled),
                        ),
                        IconButton(
                          iconSize: 50,
                          icon: Icon(
                            MdiIcons.truck,
                            color: truckToggled ? Colors.orangeAccent : Colors.grey,
                          ),
                          onPressed: () => setState(() => truckToggled = !truckToggled),
                        ),
                        IconButton(
                          iconSize: 50,
                          icon: Icon(
                            Icons.motorcycle,
                            color: motorcycleToggled ? Colors.orangeAccent : Colors.grey,
                          ),
                          onPressed: () => setState(() => motorcycleToggled = !motorcycleToggled),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Row(
                        children: <Widget>[
                          SliderTheme(
                            data: SliderThemeData(
                              thumbColor: Colors.orangeAccent,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                              inactiveTickMarkColor: Colors.black,
                              activeTickMarkColor: Colors.black,
                              activeTrackColor: Colors.orangeAccent,
                              inactiveTrackColor: Colors.grey,
                            ),
                            child: Slider(
                              min: 0,
                              max: 100,
                              value: _distanceValue,
                              divisions:  2,
                              onChanged: (value) {
                                setState(() {
                                  _distanceValue = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Row(
                        children: <Widget>[
                          SliderTheme(
                            data: SliderThemeData(
                              thumbColor: Colors.orangeAccent,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                              inactiveTickMarkColor: Colors.black,
                              activeTickMarkColor: Colors.black,
                              activeTrackColor: Colors.orangeAccent,
                              inactiveTrackColor: Colors.grey,
                            ),
                            child: Slider(
                              min: 0,
                              max: 100,
                              value: _costValue,
                              divisions:  2,
                              onChanged: (value) {
                                setState(() {
                                  _costValue = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        iconSize: 50,
                        icon: Icon(
                          Icons.accessible,
                          color: handicapToggled ? Colors.orangeAccent : Colors.grey,
                        ),
                        onPressed: () => setState(() => handicapToggled = !handicapToggled),
                      ),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Avbryt"),
                ),
                FlatButton(
                  onPressed: () => {
                    Navigator.pop(context),
                  },
                  child: Text("Klar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: TextField(
          decoration: new InputDecoration(
            hintText: 'Sök gata, adress, etc.',
            border: new OutlineInputBorder(
            ),
            prefixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {

                });
              },
            ),
          ),

        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              MdiIcons.filterMenu,
              color: _filterSwitched ? Colors.orangeAccent : Colors.grey,
            ),
            onPressed: () {
              createDialog(context);
              // do something
            },
          )
        ],
      ),
      body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Container(
                  height: 425,
                  child: GoogleMap(initialCameraPosition: CameraPosition(
                    target: LatLng(37.77483, -122.41942),
                    zoom: 12,
                  )
                    ,)
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 15),
                    FlatButton(
                        onPressed: () =>
                        {
                          navigateToFavoritesPage(context),
                        },
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.favorite, size: 45, color: Colors.grey),
                            Text(
                                "Favoriter",
                                style: TextStyle(
                                  fontSize: 13,
                                )
                            )
                          ],
                        )
                    ),
                    SizedBox(width: 20,),
                    FlatButton(
                        onPressed: () =>
                        {
                          // This button does nothing yet...
                        },
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.map, size: 45, color: Colors.orangeAccent),
                            Text(
                                "Karta",
                                style: TextStyle(
                                  fontSize: 13,
                                )
                            )
                          ],
                        )
                    ),
                    SizedBox(width: 20,),
                    FlatButton(
                        onPressed: () =>
                        {
                          navigateToSettingsPage(context),
                        },
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.settings, size: 45, color: Colors.grey),
                            Text(
                                "Inställningar",
                                style: TextStyle(
                                  fontSize: 13,
                                )
                            )
                          ],
                        )
                    ),
                  ],
                ),
              )
            ],
          )
      )
      ,);
  }
}