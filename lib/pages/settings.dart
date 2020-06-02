import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezsgame/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'package:ezsgame/pages/SizeConfig.dart';
import 'package:ezsgame/pages/forgotPassword.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.auth, this.userId, this.logoutCallback, this.parent})
      : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final HomePageState parent;
}

class _SettingsPageState extends State<SettingsPage> {
  SizeConfig sizeConfig;
  final db = Firestore.instance;
  HomePageState parent;
  double _zoom;
  double localZoom;

  @override
  void initState() {
    super.initState();
    getZoom().then((double value) {
      _zoom = value;
      HomePageState.initPosition = CameraPosition(
        target: LatLng(59.3293, 18.0686),
        zoom: _zoom,
      );
    });
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    sizeConfig = SizeConfig();
    sizeConfig.init(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Inställningar", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
        actions: <Widget>[
          new Padding(
              padding: EdgeInsets.only(
                  top: SizeConfig.blockSizeVertical * 1.5,
                  bottom: SizeConfig.blockSizeVertical * 1.5,
                  right: SizeConfig.blockSizeHorizontal * 3),
              child: FlatButton(
                  color: Colors.white,
                  child: new Text('Logga ut',
                      style: TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Container(
                              padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget> [
                              Text('Vill du logga ut från appen?'),
                              Row(children:<Widget>[Text('\n')]), //Only used for spacing, there's probably a better way
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget> [
                                  FlatButton(
                                    child: Text('Avbryt', style: TextStyle(color: Colors.orangeAccent)),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  FlatButton(
                                    child: Text('Logga ut', style: TextStyle(color: Colors.orangeAccent)),
                                    onPressed: () => signOut()
                                  )
                                ]
                              )
                            ]
                          ))
                        );
                      }
                    );
                  }
              )
          )
        ],
      ),
      body: Container(
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                contentPadding: EdgeInsets.only(
                    top: SizeConfig.blockSizeVertical * 2.2,
                    bottom: SizeConfig.blockSizeVertical * 2.2,
                    left: SizeConfig.blockSizeHorizontal * 4,
                    right: SizeConfig.blockSizeHorizontal * 4),
                title: Text(
                  'Kontoinställningar',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.blockSizeVertical * 3.5),
                ),
                subtitle: Text(
                    'Ändra lösenord, ta bort konto',
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical * 2.2)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => showAccountSettings()));
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.only(
                    top: SizeConfig.blockSizeVertical * 2.2,
                    bottom: SizeConfig.blockSizeVertical * 2.2,
                    left: SizeConfig.blockSizeHorizontal * 4,
                    right: SizeConfig.blockSizeHorizontal * 4),
                title: Text(
                  'Avstånd från destination',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.blockSizeVertical * 3.5),
                ),
                subtitle: Text(
                    'Ställ in radien från din destination du vill se parkeringar (EJ IMPLEMENTERAT)',
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical * 2.2)),
                onTap: () {
                  getZoom().then((double value) {
                    _zoom = value;
                    HomePageState.initPosition = CameraPosition(
                      target: LatLng(59.3293, 18.0686),
                      zoom: _zoom,
                    );
                    createStandardDistanceDialog(context);
                  });
                },
              ),
              ListTile(
                  //Empty ListTile to draw divider below the item above
                  ),
            ],
          ).toList(growable: false),
        ),
      ),
    );
  }

  createStandardDistanceDialog(BuildContext context) {
    localZoom = _zoom;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Ange standardzoom'),
            content: StatefulBuilder(
              builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget> [
                      Text("Långt ifrån",
                        style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical * 2.5)),
                      Text("Nära",
                        style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical * 2.5))
                    ]
                  ),
                  Slider (
                    value: localZoom,
                    min: 15,
                    max: 18,
                    divisions: 3,
                    activeColor: Colors.orangeAccent,
                    inactiveColor: Colors.black,
                    onChanged: (value) {
                      setState(() {
                        localZoom = value;
                      });
                    },
                  ),
                ]);
              }
            ),
            actions: <Widget>[
            showDoneButton(context),
          ]);
        });
  }

  //Borrowed from https://stackoverflow.com/questions/24085385/checking-if-string-is-numeric-in-dart

  Widget showDoneButton(BuildContext context) {
    return FlatButton(
        onPressed: () => {
              _zoom = localZoom,
              changeZoomSetting(localZoom),
              Navigator.pop(context),
            },
        child: Text('Spara'),
        textColor: Colors.black,
        color: Colors.orangeAccent);
  }

  Widget showAccountSettings() {
    return Scaffold(
        appBar: AppBar(
            title: Text('Kontoinställningar',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.orangeAccent,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => {
                      Navigator.pop(context),
                    })),
        body: Container(
            child: ListView(
          children: ListTile.divideTiles(context: context, tiles: [
            ListTile(
              contentPadding: EdgeInsets.only(
                  top: SizeConfig.blockSizeVertical * 2.2,
                  bottom: SizeConfig.blockSizeVertical * 2.2,
                  left: SizeConfig.blockSizeHorizontal * 4,
                  right: SizeConfig.blockSizeHorizontal * 4),
              title: Text(
                'Återställ lösenord',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.blockSizeVertical * 3.5),
              ),
              subtitle: Text(
                  'Återställ ditt lösenord genom en länk du får via e-mail',
                  style:
                      TextStyle(fontSize: SizeConfig.blockSizeVertical * 2.2)),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPassword(
                            auth: widget.auth, loginCallback: widget.logoutCallback)));
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(
                  top: SizeConfig.blockSizeVertical * 2.2,
                  bottom: SizeConfig.blockSizeVertical * 2.2,
                  left: SizeConfig.blockSizeHorizontal * 4,
                  right: SizeConfig.blockSizeHorizontal * 4),
              title: Text(
                'Ta bort konto',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.blockSizeVertical * 3.5),
              ),
              subtitle: Text(
                'Raderar ditt konto med all historik och sparade favoriter'
              ),
              onTap: () {
                showRemoveAccountConfirmation(context);
              },
            ),
            ListTile(
                //Empty ListTile to draw divider below the item above
                ),
          ]).toList(growable: false),
        )));
  }

  showRemoveAccountConfirmation(BuildContext context) {
    showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(''),
            content: Text("Är du säker på att du vill ta bort ditt konto?"),
            actions: [
              FlatButton(
                child: Text('Ja'),
                onPressed: () {
                  deleteCurrentUser();
                },
              ),
              FlatButton(
                child: Text('Nej'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future deleteCurrentUser() async {
    String uId = widget.userId;

    QuerySnapshot snapshot = await Firestore.instance
        .collection('userData')
        .document(uId)
        .collection('favorites')
        .getDocuments();

    for (DocumentSnapshot v in snapshot.documents) {
      db
          .collection('userData')
          .document(uId)
          .collection('favorites')
          .document(v.documentID)
          .delete();
    }

    FirebaseUser user = await widget.auth.getCurrentUser();
    user.delete();
    signOut();
  }

  void changeZoomSetting(double newVal) async{
    String uId = widget.userId;

    db.collection('userData')
        .document(uId)
        .collection('settings')
        .document('SettingsData')
        .setData({
        'zoom' : newVal,
    });
    setState(() {
      HomePageState.initPosition = CameraPosition(
        target: LatLng(59.3293, 18.0686),
        zoom: _zoom,
      );
    });
  }

  Future<double> getZoom() async{
    DocumentSnapshot snap = await db.collection('userData')
        .document(widget.userId)
        .collection('settings').document('SettingsData').get();
    if(snap.exists && snap.data["zoom"] != null) {
      return snap.data["zoom"];
    }else{
      String uId = widget.userId;
      db.collection('userData')
          .document(uId)
          .collection('settings')
          .document('SettingsData')
          .setData({
        'zoom' : 15,
      });
      return 15;
    }
  }
}


