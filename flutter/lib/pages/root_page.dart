/*
import 'package:ezsgame/widgets/signin/sign_up.dart';
import 'package:flutter/material.dart';


enum AuthStats {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => _RootPageState();


}

class _RootPageState extends State<RootPage> {
  AuthStats authStats = AuthStats.NOT_DETERMINED;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStats = user?.uid == null ? AuthStats.NOT_LOGGED_IN : AuthStats.LOGGED_IN;

      });
    });
  }



  void loginCallBack() {
    widget.auth.getCurrent().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStats = AuthStats.LOGGED_IN;
      _userId = "";
    });
  }

  void logoutCallback() {
    setState(() {
      authStats = AuthStats.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStats) {
      case AuthStats.NOT_DETERMINED:
        return null;
        break;
      case AuthStats.NOT_LOGGED_IN:
        return new SignUp()
    }
  }

}*/
