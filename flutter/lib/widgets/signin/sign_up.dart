import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      children: <Widget>[
        Text('Not registered?'),
        FlatButton(
          textColor: Colors.greenAccent,
          child: Text(
            'Sign up',
            style: TextStyle(
              fontSize: 15,
              decoration: TextDecoration.underline,
            ),
          ),
          onPressed: () {
            /* Navigator.push(
                context, MaterialPageRoute(builder: (context) => signUp()));*/
          },
        )
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    ));
  }
}
