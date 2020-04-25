import 'package:ezsgame/widgets/signin/facebook_login.dart';
import 'package:ezsgame/widgets/signin/google_login.dart';
import 'package:ezsgame/widgets/signin/sign_in_button.dart';
import 'package:ezsgame/widgets/signin/signin_password.dart';
import 'package:flutter/material.dart';
import 'package:ezsgame/widgets/signin/logo.dart';
import 'package:ezsgame/widgets/signin/signin_email.dart';
import 'package:ezsgame/widgets/signin/keep_signed.dart';
import 'package:ezsgame/widgets/signin/forgot_password.dart';
import 'package:ezsgame/widgets/signin/sign_up.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.only(left: 60, right: 60, bottom: 40, top: 30),
      child: ListView(
        children: <Widget>[
          Logo(),
          SignInEmail(),
          SignInPassword(),
          ForgotPassword(),
          KeepSigned(),
          SignIn(),
          SignUp(),
          FacebookLogin(),
          GoogleLogin(),
        ],
      ),
    ));
  }
}
