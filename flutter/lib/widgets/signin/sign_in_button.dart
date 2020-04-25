import 'package:flutter/material.dart';
import 'package:ezsgame/widgets/signin/signin_email.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 90, right: 90),
        child: RaisedButton(
          textColor: Colors.black,
          color: Colors.greenAccent,
          child: Text('Sign In'),
          onPressed: () {
            /*print(nameController.text);
            print(passwordController.text);*/
          },
        ));
  }
}
