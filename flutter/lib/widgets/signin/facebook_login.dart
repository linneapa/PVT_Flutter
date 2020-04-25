import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

class FacebookLogin extends StatefulWidget {
  @override
  _FacebookLoginState createState() => _FacebookLoginState();
}

class _FacebookLoginState extends State<FacebookLogin> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: EdgeInsets.only(top: 0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 10),
          FacebookSignInButton(onPressed: () {
            // ADD AUTH LOGIC HERE
          }),
        ],
      ),
    );
  }
}
