import 'package:flutter/material.dart';

class SignInPassword extends StatefulWidget {
  @override
  _SignInPasswordState createState() => _SignInPasswordState();
}

class _SignInPasswordState extends State<SignInPassword> {
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: TextField(
        obscureText: true,
        controller: passwordController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Password',
        ),
      ),
    );
  }
}
