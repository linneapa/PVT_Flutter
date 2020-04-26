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
      title: Text("Home Page Lol"),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.settings_applications),
          tooltip: "Settings",
          onPressed: () {
            openPage(context);
          },
        )
      ],
    ));
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
