import 'package:ezsgame/firebase/authentication.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  ForgotPassword({this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => new _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = new GlobalKey<FormState>();

  String _email;

  String _errorMessage;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Återställ lösenord'),
      ),
      body: _showForm(),
    );
  }

  Widget _showForm() {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Padding(
            padding: EdgeInsets.only(left: 60, right: 60, bottom: 40, top: 30),
            child: new Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Text("\n     E-postadress"),
                  showEmailInputField(),
                  showErrorMessage(),
                  showResetPasswordButton(),
                ],
              ),
            )));
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    form.save();

    if (form.validate()) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    _errorMessage = "";
    super.initState();
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void toggleFormMode() {
    resetForm();
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
    });
    if (validateAndSave()) {
      String userId = "";
      try {
        bool emailExists = await widget.auth.sendPasswordResetEmail(_email);
        if(emailExists) {
          _showResetDialog();
          print('Reset password for user: $userId');
        } else{
          _errorMessage = "Användaren hittades ej."; 
          setState(() {});
        }
      } catch (e) {
        print('Error: $e');
        bool _undefinedError = false;

        switch (e.code) {
          case "ERROR_INVALID_EMAIL":
            _errorMessage = "Ogiltlig formattering av e-postadress.";
            break;
          default:
            _undefinedError = true;
            _errorMessage = "Ett oväntat fel inträffade.";
        }

        setState(() {
          if (_undefinedError) _formKey.currentState.reset();
        });
      }
    }
  }

  Widget showEmailInputField() {
    return Container(
      padding: EdgeInsets.all(15),
      child: TextFormField(
          maxLines: 1,
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: new InputDecoration(
            hintText: 'E-postadress',
            border: OutlineInputBorder(),
          ),
          validator: (valueOfInputField) => valueOfInputField.isEmpty ? "Vänligen fyll i din e-postadress":null,
          onSaved: (String valueOfInputField) { _email = valueOfInputField.trim();
  
          }),
    );
  }

  Widget showResetPasswordButton() {
    return Container(
        padding: EdgeInsets.only(left: 90, right: 90),
        child: RaisedButton(
          textColor: Colors.black,
          color: Colors.greenAccent,
          child: Text('Återställ'),
          onPressed: validateAndSubmit,
        ));
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Återställ ditt lösenord"),
          content: new Text(
              "En länk för att återställa ditt lösenord har skickats till den angivna e-postadressen."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Avfärda"),
              onPressed: () {
                toggleFormMode();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Container(
        padding: EdgeInsets.only(top: 15),
        alignment: Alignment.bottomCenter,
        child: Text(
          _errorMessage,
          style: TextStyle(
              fontSize: 13.0,
              color: Colors.red,
              height: 1.0,
              fontWeight: FontWeight.w300),
        ),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }
}
