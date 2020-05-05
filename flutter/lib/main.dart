import 'package:ezsgame/pages/root_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'firebase/authentication.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        home: new RootPage(auth: new Auth())
    );
  }
}
