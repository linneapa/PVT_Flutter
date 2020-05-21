import 'package:flutter/material.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavouritesPage extends StatefulWidget {
  @override
  _FavouritesPageState createState() => _FavouritesPageState(value);

  FavouritesPage(
      {Key key, this.userId, this.auth, this.logoutCallback, this.value})
      : super(key: key);

  final String userId;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String value;

}

class _FavouritesPageState extends State<FavouritesPage> {
  String value;

  _FavouritesPageState(this.value);

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Favoriter", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.greenAccent,
          actions: <Widget>[],
        ),
        body: Container(
            child: StreamBuilder(
                stream: getUserFavoriteParkings(context),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return const Text("Loading...");
                  return new ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) =>
                          buildFavoriteCard(context, snapshot.data.documents[index]));
                })
        )
    );
  }

  Stream<QuerySnapshot> getUserFavoriteParkings(BuildContext context) async* {

    String uId = widget.userId;

    yield* Firestore.instance.collection('userData').document(uId).collection('favorites').snapshots();
  }

  Widget buildFavoriteCard(BuildContext context, DocumentSnapshot parking) {
    return new Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(parking['location'], style: new TextStyle(fontSize: 14)),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(parking['type'], style: new TextStyle(fontSize: 10)),
                ],
              )
            ],
          )
        )
      )
    );
  }
}
