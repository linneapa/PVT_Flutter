import 'package:flutter/material.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ezsgame/firebase/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FavouritesPage extends StatefulWidget {
  @override
  _FavouritesPageState createState() => _FavouritesPageState(value);

  FavouritesPage({Key key, this.auth, this.logoutCallback, this.value})
      : super(key: key);
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String value;


}

class _FavouritesPageState extends State<FavouritesPage> {

  String value;
  _FavouritesPageState(this.value);



  List<String> savedParkings = [
    'Kungsgatan',
    'Tranbergsvägen'
  ];

  void update() {
    savedParkings.add(value);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Favoriter", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.greenAccent,
        actions: <Widget>[],
      ),
      body: Container(
        //child: new FavoritesList(),
      ),
    );
  }



}

//class FavoritesList extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return StreamBuilder<QuerySnapshot>(
//      stream: Firestore.instance.collection('favorites').snapshots(),
//      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//        if (snapshot.hasError)
//          return new Text('Error: ${snapshot.error}');
//        switch (snapshot.connectionState) {
//          case ConnectionState.waiting: return new Text('Loading...');
//          default:
//            return new ListView(
//              children: snapshot.data.documents.map((DocumentSnapshot document) {
//                return new ListTile(
//                  title: new Text(document['type']),
//                  subtitle: new Text(document['location']),
//                );
//              }).toList(),
//            );
//        }
//      },
//    );
//  }
//}
//