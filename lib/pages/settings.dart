import 'package:flutter/material.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'package:ezsgame/pages/SizeConfig.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key key, this.auth, this.logoutCallback})
      : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();

  final BaseAuth auth;
  final VoidCallback logoutCallback;
}

class _SettingsPageState extends State<SettingsPage> {

  SizeConfig sizeConfig;

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
          new FlatButton(
              child: new Text(
                  'Logga ut', style: TextStyle(color: Colors.white)),
              onPressed: signOut)
        ],
      ),
      body: Container(
        child:ListView(
          children: ListTile.divideTiles(
              context: context,
              tiles: [ //TEMPORARY ITEMS
                ListTile(
                  contentPadding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2.2, bottom: SizeConfig.blockSizeVertical * 2.2, left: SizeConfig.blockSizeHorizontal * 4, right: SizeConfig.blockSizeHorizontal * 4),
                  title: Text('Kontoinställningar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.blockSizeVertical * 3.5
                    ),
                  ),
                  subtitle: Text('Ändra lösenord, ta bort konto (Denna text kommer ändras)',
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeVertical * 2.2
                    )
                  ),
                  onTap: () {
                    //Do something
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2.2, bottom: SizeConfig.blockSizeVertical * 2.2, left: SizeConfig.blockSizeHorizontal * 4, right: SizeConfig.blockSizeHorizontal * 4),
                  title: Text('Avstånd från destination',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.blockSizeVertical * 3.5
                    ),
                  ),
                  subtitle: Text('Ställ in radien från din destination du vill se parkeringar',
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeVertical * 2.2
                    )
                  ),
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Avstånd i meter',
                  hintText: 'Radie inom vilken du ser parkeringar',
                ),
                onSaved: (String value){
                  //Save the distance entered
                },
                validator: (String value){
                  return isNumeric(value) ? 'Var god ange ett nummer.' : null;
                }
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget> [
                  showCancelButton(context),
                  showSaveButton(context),
                ]
              ),
            ]
          )
        );
      }
    );
  }

  //Borrowed from https://stackoverflow.com/questions/24085385/checking-if-string-is-numeric-in-dart
  bool isNumeric(String str){
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
      color: Colors.orangeAccent
    );
  }

  Widget showSaveButton(BuildContext context) {
    return FlatButton(
      onPressed: () => {
        //Save content locally
        Navigator.pop(context),
      },
      child: Text('Spara'),
      color: Colors.orangeAccent
    );
  }

}

