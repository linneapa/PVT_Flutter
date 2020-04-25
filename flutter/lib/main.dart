import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MyApp> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool keepMeLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: EdgeInsets.only(left: 60, right: 60, bottom: 40, top: 30),
            child: ListView(
              children: <Widget>[
                Container(
                  alignment: Alignment(0, -0.7),
                  padding: EdgeInsets.only(top: 40.0, bottom: 15),
                  child: Image.asset(
                    "assets/logo.png",
                    width: 95,
                    height: 95,
//        fit: BoxFit.cover,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    //forgot password screen
                  },
                  textColor: Colors.greenAccent,
                  child: Text('Forgot Password'),
                ),
                CheckboxListTile(
                  title: Text("Keep me signed in."),
                  value: keepMeLoggedIn,
                  onChanged: (newValue) {
                    print("Checkin");
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                Container(
                    padding: EdgeInsets.only(left: 90, right: 90),
                    child: RaisedButton(
                      textColor: Colors.black,
                      color: Colors.greenAccent,
                      child: Text('Login'),
                      onPressed: () {
                        print(nameController.text);
                        print(passwordController.text);
                      },
                    )),
                Container(
                    child: Row(
                  children: <Widget>[
                    Text('Does not have account?'),
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
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => signUp()));
                      },
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                )),
                Container(
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
                ),
                Container(
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
                ),
              ],
            )));
  }
}

class signUp extends StatelessWidget {
  TextEditingController emailController = TextEditingController();
  TextEditingController emailConfirmationController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController =
      TextEditingController();

  bool AgreeTermsAndConditions = false;

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sign Up'),
        ),
        body: Padding(
            padding: EdgeInsets.only(left: 60, right: 60, bottom: 40, top: 50),
            child: ListView(children: <Widget>[
              Container(
                padding: EdgeInsets.all(15),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'E-mail',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                child: TextField(
                  controller: emailConfirmationController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm E-mail',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                child: TextField(
                  controller: passwordConfirmationController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm password',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: CheckboxListTile(
                  title: Text("I agree to the Term & Conditions."),
                  value: AgreeTermsAndConditions,
                  onChanged: (newValue) {
                    print("Checkin");
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
              ),
              Container(
                  padding: EdgeInsets.only(left: 90, right: 90),
                  child: RaisedButton(
                    textColor: Colors.black,
                    color: Colors.greenAccent,
                    child: Text('Sign up'),
                    onPressed: () {},
                  )),
            ])));
  }
}
