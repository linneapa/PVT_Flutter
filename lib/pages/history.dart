import 'package:flutter/material.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'home_page.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState(value, this.parent);

  HistoryPage(
      {Key key, this.userId, this.auth, this.logoutCallback, this.value, this.parent})
      : super(key: key);

  final String userId;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String value;
  final HomePageState parent;
}

class _HistoryPageState extends State<HistoryPage> {
  String value;
  final db = Firestore.instance;
  HomePageState parent;

  _HistoryPageState(this.value, this.parent);

  @override
  void initState() {
    super.initState();
    HomePageState.doc = null;
    HomePageState.initPosition = CameraPosition(
      target: LatLng(59.3293, 18.0686),
      zoom: 12,
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        automaticallyImplyLeading: false,
        title: Text('Senast valda destinationer', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        child: StreamBuilder(
            stream: getUserHistoryParkings(context),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return const Text("Loading..");
              return new ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) =>
                      buildHistoryCard(
                          context, snapshot.data.documents[index]));
            }),
      ),
    );
  }

  Stream<QuerySnapshot> getUserHistoryParkings(BuildContext context) async* {
    String uId = widget.userId;
    yield* Firestore.instance
        .collection('userData')
        .document(uId)
        .collection('history').orderBy('timestamp', descending: true)
        .snapshots();
  }

  Icon getVehicleTypeIcon(DocumentSnapshot parking) {
    if (parking['vehicleType'] == 'car') {
      return new Icon(Icons.directions_car);
    }
    else if (parking['vehicleType'] == 'motorcykel') {
      return new Icon(Icons.motorcycle);
    }
    else if (parking['vehicleType'] == 'lastbil') {
      return new Icon(MdiIcons.truck);
    }
    else if (parking['vehicleType'] == 'handicap') {
      return new Icon(Icons.accessible);
    }
    return new Icon(Icons.directions_car);
  }


  //TODO: sort cards by timestamp
  Widget buildHistoryCard(BuildContext context, DocumentSnapshot parking) {
    return new Container(
        child: new GestureDetector(
      onTap: () => showOnCardTapDialogue(parking),
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(parking['location'],
                          style: new TextStyle(fontSize: 14)),
                      SizedBox(width: 10,),
                      getVehicleTypeIcon(parking),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(parking['district'],
                          style: new TextStyle(fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('Användes senast: ' + parking['timestamp'],
                          style: new TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ))),
    ));
  }

  Future<void> showOnCardTapDialogue(DocumentSnapshot doc) async {

    String location = doc['location'];
    String district = doc['district'];
    String info = doc['info'];
    String maxTimmar = doc['maxTimmar'];

    if (district == 'null') {
      district = 'saknas';
    }

    if (info == 'null') {
      info = 'saknas';
    }

    if (maxTimmar == 'null') {
      maxTimmar = 'saknas';
    }


    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(''),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(location, style: TextStyle(fontSize: 16)),
                Text('Stadsdel: ' + district, style: TextStyle(fontSize: 14)),
                Text('Övrig info: ' + info, style: TextStyle(fontSize: 14)),
                Text('Max timmar: ' + maxTimmar, style: TextStyle(fontSize: 14)),
              ]
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ta bort'),
              onPressed: () {
                showRemoveConfirmationDialogue(doc);
              },
            ),
            FlatButton(
              child: Text('Visa på karta'),
              onPressed: () {
                Navigator.of(context).pop();
                showParkingOnMapPage(doc);
              },
            ),
            FlatButton(
              child: Text('Avbryt'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future showRemoveConfirmationDialogue(DocumentSnapshot doc) {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(''),
            content: Text("Är du säker på att du vill ta bort " + doc['location'] + " från din historik?"),
            actions: [
              FlatButton(
                child: Text('Ja'),
                onPressed: () {
                  deleteHistoryParking(doc);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Nej'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  showParkingOnMapPage(DocumentSnapshot doc) {

    this.parent.setState(() {
      HomePageState.currentNavigationIndex = 2;
      HomePageState.doc = doc;
      HomePageState.initPosition = CameraPosition(
          target: LatLng(doc['coordinatesX'], doc['coordinatesY']),
          zoom: 12);
    });
  }

  void deleteHistoryParking(DocumentSnapshot doc) async {
    String uId = widget.userId;
    try {
      db
          .collection('userData')
          .document(uId)
          .collection('history')
          .document(doc.documentID)
          .delete();
    } catch (e) {
      print('Error: $e');
    }
  }
}
