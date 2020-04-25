import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

class GoogleLogin extends StatefulWidget {
  @override
  _GoogleLoginState createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: EdgeInsets.only(top: 0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 2),
          GoogleSignInButton(
            onPressed: () {
              // ADD AUTH LOGIC HERE
            },
            darkMode: true,
          ),
        ],
      ),
    );
  }
}
