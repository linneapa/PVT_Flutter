import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezsgame/pages/login_sign_up.dart';
import 'package:ezsgame/pages/root_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'package:ezsgame/pages/SizeConfig.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
}

class _SettingsPageState extends State<SettingsPage> {
  SizeConfig sizeConfig;
  final db = Firestore.instance;

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
                  onPressed: signOut))
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
                  createStandardDistanceDialog(context);
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
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content:
                  Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Avstånd i meter',
                  hintText: 'Radie inom vilken du ser parkeringar',
                ),
                onSaved: (String value) {
                  //Save the distance entered
                },
                validator: (String value) {
                  return isNumeric(value) ? 'Var god ange ett nummer.' : null;
                }),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  showCancelButton(context),
                  showSaveDistButton(context),
                ]),
          ]));
        });
  }

  //Borrowed from https://stackoverflow.com/questions/24085385/checking-if-string-is-numeric-in-dart
  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  Widget showCancelButton(BuildContext context) {
    return FlatButton(
        onPressed: () => {
              Navigator.pop(context),
            },
        child: Text('Avbryt'),
        color: Colors.orangeAccent);
  }

  Widget showSaveDistButton(BuildContext context) {
    return FlatButton(
        onPressed: () => {
              //Save content locally
              Navigator.pop(context),
            },
        child: Text('Spara'),
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
                'Byt lösenord',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.blockSizeVertical * 3.5),
              ),
              subtitle: Text(
                  'Denna funktionalitet är ej implementerad än, lösenord kan återställas genom \"Glömt ditt lösenord?\" vid inloggning.',
                  style:
                      TextStyle(fontSize: SizeConfig.blockSizeVertical * 2.2)),
              onTap: () {
                createChangePasswordDialog(context);
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

  //Not sure if this should be handled in-app or if it should be the same as password reset
  createChangePasswordDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content:
                  Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nytt lösenord',
              ),
              onSaved: (String value) {
                //Save new password
              },
            ),
            TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Bekräfta nytt lösenord')),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  showCancelButton(context),
                  showSavePassButton(context),
                ]),
          ]));
        });
  }

  Widget showSavePassButton(BuildContext context) {
    return FlatButton(
        onPressed: () => {
              //Validate that both fields are filled and content is identical
              //Save content in Firebase
              Navigator.pop(context),
            },
        child: Text('Spara'),
        color: Colors.orangeAccent);
  }
}
