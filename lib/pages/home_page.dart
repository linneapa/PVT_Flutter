import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'package:flutter/foundation.dart';
import 'settings.dart';
import 'favorites.dart';
import 'map_page.dart';
import 'history.dart';
import 'package:flutter/widgets.dart';


class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();

  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
}

class HomePageState extends State<HomePage> {

  static int currentNavigationIndex = 1;

  List<Widget> _tabs() => [
    FavouritesPage(
      userId: widget.userId,
      auth: widget.auth,
      logoutCallback: widget.logoutCallback,
      parent: this),
    MapPage(
      userId: widget.userId,
      auth: widget.auth,
      logoutCallback: widget.logoutCallback,),
    SettingsPage(
      userId: widget.userId,
      auth: widget.auth,
      logoutCallback: widget.logoutCallback,),
    HistoryPage(
      userId: widget.userId,
      auth: widget.auth,
      logoutCallback: widget.logoutCallback,
      parent: this),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = _tabs();

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: tabs[currentNavigationIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentNavigationIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.orangeAccent,
          unselectedItemColor: Colors.grey,
          iconSize: 45,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                title: Text('Favoriter')
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.map),
                title: Text('Karta')
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                title: Text('Inställningar')
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.history),
                title: Text('Historik')
            ),
          ],
          onTap: (index) {
            setState(() {
              currentNavigationIndex = index;
              print(_tabs().toString());
            });
          }
      ),
    );
  }
}
