import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'settings.dart';
import 'favorites.dart';

class Close2MePage extends StatefulWidget{
  @override
  _Close2MePageState createState() => _Close2MePageState();

  Close2MePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
}

class _Close2MePageState extends State<Close2MePage> {

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
   // Navigator.push(context, MaterialPageRoute(builder: (context) => new Close2MePage()));
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
              color: Colors.grey,
            ),
            onPressed: () {
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
