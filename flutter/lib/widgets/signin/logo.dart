import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(0, -0.7),
      padding: EdgeInsets.only(top: 40.0, bottom: 15),
      child: Image.asset(
        "assets/logo.png",
        width: 95,
        height: 95,
//        fit: BoxFit.cover,
      ),
    );
  }
}
