import 'package:flutter/material.dart';
import 'package:ezsgame/firebase/authentication.dart';

class FavouritesPage extends StatefulWidget {
  @override
  _FavouritesPageState createState() => _FavouritesPageState();

  FavouritesPage({Key key, this.auth, this.logoutCallback})
      : super(key: key);
  final BaseAuth auth;
  final VoidCallback logoutCallback;
}

class _FavouritesPageState extends State<FavouritesPage> {

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Favoriter", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.greenAccent,
        actions: <Widget>[],
      ),
      body: Container(),
    );
  }

}
