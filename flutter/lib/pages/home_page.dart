import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      title: Text("Parking App", style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.greenAccent,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.settings, color: Colors.white, size: 40),
          tooltip: "Settings",
          onPressed: () {
            openPage(context);
          },
        )
      ],
    ),
        body: Container(
            padding: EdgeInsets.only(left: 45, right: 45),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 30),
                RaisedButton(
                    padding: const EdgeInsets.all(16),
                    onPressed: () => {},
                    color: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5)
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.favorite, size: 45, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                            "Favourites",
                            style: TextStyle(
                              fontSize: 20,
                            )
                        )
                      ],
                    )
                ),
                SizedBox(height: 20),
                RaisedButton(
                    padding: const EdgeInsets.all(16),
                    onPressed: () => {},
                    color: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(7)
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                            Icons.person_pin_circle, size: 45, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                            "Close to me",
                            style: TextStyle(
                              fontSize: 20,
                            )
                        )
                      ],
                    )
                ),
                SizedBox(height: 20),
                RaisedButton(
                    padding: const EdgeInsets.all(16),
                    onPressed: () => {},
                    color: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(7)
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.search, size: 45, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                            "Search",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                        ),
                      ],
                    ),
                )
              ],
            ),
        ),
    );
  }
}

void openPage(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[Text("NOTHING HERE!")],
        ),
      ),
    );
  }));
}
