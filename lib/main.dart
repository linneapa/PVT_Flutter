import 'package:ezsgame/pages/map_page.dart';
import 'package:ezsgame/pages/root_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'firebase/authentication.dart';
import 'package:ezsgame/pages/home_page.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PVT map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      //home: new RootPage(auth: new Auth())
      home: new HomePage(),
    );
  }
}
