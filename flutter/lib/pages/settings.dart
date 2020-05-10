import 'package:flutter/material.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'dart:async';
import 'map_page.dart';
import 'favorites.dart';
import 'SizeConfig.dart';

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
    Navigator.push(context, MaterialPageRoute(builder: (context) => new FavouritesPage(
      auth: widget.auth,
      logoutCallback: widget.logoutCallback,
    )));
  }

  Future navigateToMapPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => new MapPage(
      auth: widget.auth,
      logoutCallback: widget.logoutCallback,
    )));
  }

  Future navigateToCurrentPage(context) async {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => new SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
              SizedBox(height: SizeConfig.blockSizeVertical * 75),
              Expanded( // Code for the bottom navigation bar below.
                child: Row(
                  children: <Widget>[
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 5),
                    showFavoritesNavigationButton(),
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 7),
                    showMapNavigationButton(),
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 7),
                    showSettingsNavigationButton(),
                  ],
                ),
              )
            ],
          )
      ),
    );
  }

  Widget showFavoritesNavigationButton() {
    return FlatButton(
        onPressed: () => {navigateToFavoritesPage(context)},
        child: Column(
          children: <Widget>[
            Icon(Icons.favorite, size: 45, color: Colors.grey),
            Text(
                "Favoriter",
                style: TextStyle(fontSize: 13))
          ],
        )
    );
  }

  Widget showMapNavigationButton() {
    return FlatButton(
        onPressed: () => {navigateToMapPage(context)},
        child: Column(
          children: <Widget>[
            Icon(Icons.map, size: 45, color: Colors.grey),
            Text(
                "Karta",
                 style: TextStyle(fontSize: 13)
            )
          ],
        )
    );
  }

  Widget showSettingsNavigationButton() {
    return FlatButton(
        onPressed: () => {navigateToCurrentPage(context),},
        child: Column(
          children: <Widget>[
            Icon(Icons.settings, size: 45, color: Colors.orangeAccent),
            Text(
                "Inställningar",
                style: TextStyle(fontSize: 13,)
            )
          ],
        )
    );
  }

}

