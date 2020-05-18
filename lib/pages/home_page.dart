import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'package:flutter/foundation.dart';
import 'settings.dart';
import 'favorites.dart';
import 'map_page.dart';
import 'package:flutter/widgets.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();

  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
}

class _HomePageState extends State<HomePage> {

  int _currentNavigationIndex = 1;

  final List<Widget> _tabs = [
    FavouritesPage(),
    MapPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: _tabs[_currentNavigationIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentNavigationIndex,
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
          ],
          onTap: (index) {
            setState(() {
              _currentNavigationIndex = index;
            });
          }
      ),
    );
  }
}
