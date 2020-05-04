import 'package:flutter/material.dart';
import 'settings.dart';
import 'close2me.dart';

class FavouritesPage extends StatefulWidget {
  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

  class _FavouritesPageState extends State<FavouritesPage> {

    Future navigateToSettingsPage(context) async {
      Navigator.push(context, MaterialPageRoute(builder: (context) => new SettingsPage()));
    }

    Future navigateToMapPage(context) async {
      Navigator.push(context, MaterialPageRoute(builder: (context) => new Close2MePage()));
    }

    Future navigateToCurrentPage(context) async {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => new FavouritesPage()));
    }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favoriter", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.greenAccent,
        actions: <Widget>[
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            SizedBox(height: 425),
            Expanded(
              child: Row(
                children: <Widget>[
                  SizedBox(width: 15),
                  FlatButton(
                      onPressed: () =>
                      {
                        navigateToCurrentPage(context),
                      },
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.favorite, size: 45, color: Colors.orangeAccent),
                          Text(
                              "Favoriter",
                              style: TextStyle(
                                fontSize: 13,
                              )
                          )
                        ],
                      )
                  ),
                  SizedBox(width: 20,),
                  FlatButton(
                      onPressed: () =>
                      {
                        navigateToMapPage(context)
                      },
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.map, size: 45, color: Colors.grey),
                          Text(
                              "Karta",
                              style: TextStyle(
                                fontSize: 13,
                              )
                          )
                        ],
                      )
                  ),
                  SizedBox(width: 20,),
                  FlatButton(
                      onPressed: () =>
                      {
                        navigateToSettingsPage(context),
                      },
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.settings, size: 45, color: Colors.grey),
                          Text(
                              "Inställningar",
                              style: TextStyle(
                                fontSize: 13,
                              )
                          )
                        ],
                      )
                  ),
                ],
              ),
            )
          ],
        )
      ),
    );
  }


}
