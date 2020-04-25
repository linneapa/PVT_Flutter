import 'package:flutter/material.dart';

class SignInEmail extends StatefulWidget {
  @override
  _SignInEmailState createState() => _SignInEmailState();
}

class _SignInEmailState extends State<SignInEmail> {
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: TextField(
        controller: nameController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Email',
        ),
      ),
    );
  }
}
