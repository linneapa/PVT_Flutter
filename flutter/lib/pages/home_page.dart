import 'package:ezsgame/firebase/authentication.dart';
import 'package:flutter/material.dart';
import 'favorites.dart';
import 'close2me.dart';
import 'search.dart';
import 'settings.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.auth, this.userId, this.logoutCallback})
      : super(key: key);
  final String title;

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final buttonColor = Colors.greenAccent; // set color for all buttons here
  final iconColor = Colors.white; // set color for all icons here

  Future navigateToSettingsPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => new SettingsPage()));
  }

  Future navigateToFavouritesPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => new FavouritesPage()));
  }

  Future navigateToClose2MePage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => new Close2MePage()));
  }

  /*Future navigateToSearchPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => new SearchPage()));
  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parking App', style: TextStyle(color: Colors.white)),
        backgroundColor: buttonColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings, color: iconColor, size: 40),
            tooltip: "Inställning",
            onPressed: () {
              navigateToSettingsPage(context);
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 45, right: 45),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30),
            RaisedButton(
                padding: const EdgeInsets.all(16),
                onPressed: () =>
                {
                  navigateToFavouritesPage(context),
                },
                color: buttonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5)
                ),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.favorite, size: 45, color: iconColor),
                    SizedBox(width: 5),
                    Text(
                        "Favoriter",
                        style: TextStyle(
                          fontSize: 20,
                        )
                    )
                  ],
                )
            ),
            SizedBox(height: 20),
            RaisedButton(
                padding: const EdgeInsets.all(16),
                onPressed: () =>
                {
                  navigateToClose2MePage(context)
                },
                color: buttonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(7)
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                        Icons.person_pin_circle, size: 45, color: iconColor),
                    SizedBox(width: 5),
                    Text(
                        "Nära mig",
                        style: TextStyle(
                          fontSize: 20,
                        )
                    )
                  ],
                )
            ),
            SizedBox(height: 20),
            RaisedButton(
              padding: const EdgeInsets.all(16),
              onPressed: () =>
              {
                //navigateToSearchPage(context)
              },
              color: buttonColor,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(7)
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.search, size: 45, color: iconColor),
                  SizedBox(width: 5),
                  Text(
                    "Sök",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

