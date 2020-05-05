import 'package:flutter/material.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'dart:async';
import 'close2me.dart';
import 'favorites.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key key, this.auth, this.logoutCallback})
      : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();

  final BaseAuth auth;
  final VoidCallback logoutCallback;
}

class _SettingsPageState extends State<SettingsPage> {

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      print(e);
    }
  }

  Future navigateToFavoritesPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => new FavouritesPage()));
  }

  Future navigateToMapPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => new Close2MePage()));
  }

  Future navigateToCurrentPage(context) async {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => new SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inställningar", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.greenAccent,
        actions: <Widget>[
          new FlatButton(
              child: new Text(
                  'Logga ut', style: TextStyle(color: Colors.white)),
              onPressed: signOut)
        ],
      ),
      body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SizedBox(height: 425),
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
                          navigateToMapPage(context)
                        },
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.map, size: 45, color: Colors.grey),
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
                          navigateToCurrentPage(context),
                        },
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.settings, size: 45, color: Colors.orangeAccent),
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
      ),
    );
  }
}

