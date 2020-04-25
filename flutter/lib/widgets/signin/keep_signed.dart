import 'package:flutter/material.dart';

class KeepSigned extends StatefulWidget {
  @override
  _KeepSignedState createState() => _KeepSignedState();
}

class _KeepSignedState extends State<KeepSigned> {
  bool keepMeLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text("Keep me signed in."),
      value: keepMeLoggedIn,
      onChanged: (newValue) {
        print("Checkin");
      },
      controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
    );
  }
}
