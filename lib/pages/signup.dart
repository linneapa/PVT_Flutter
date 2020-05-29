import 'package:ezsgame/firebase/authentication.dart';
import 'package:flutter/material.dart';
import 'package:ezsgame/pages/SizeConfig.dart';

/*
TODO:

- prevent all the answers of the form from disappearing when the user views the terms and conditions

- (fit everything on one page (when all error messages are present))

*/

class SignupPage extends StatefulWidget {
  SignupPage({this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => new _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = new GlobalKey<FormState>();

  SizeConfig sizeConfig;

  String _email, _confirmEmail, _password, _confirmPassword;
  bool _termsAndConditionsAgreement = false, _signUpBtnHasBeenPressed = false;

  String _errorMessage;

  Widget build(BuildContext context) {
    sizeConfig = SizeConfig();
    sizeConfig.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrera ny användare'),
      ),
      body: _showForm(),
    );
  }

  Widget _showForm() {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Padding(
            padding: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 10, right: SizeConfig.blockSizeHorizontal * 10, bottom: 0, top: SizeConfig.blockSizeVertical * 5),
            child: new Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  showInputField("E-postadress"),
                  showInputField("Bekräfta e-postadress"),
                  showInputField("Lösenord"),
                  showInputField("Bekräfta lösenord"),
                  showTermsAndConditionsRow(),
                  showTermsAndConditionWarning(),
                  showSignUpBtn(),
                  showErrorMessage(),
                ],
              ),
            )));
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    form.save();

    if (form.validate() && _termsAndConditionsAgreement) {
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
      _signUpBtnHasBeenPressed = true;
    });
    if (validateAndSave()) {
      String userId = "";
      try {
        userId = await widget.auth.signUp(_email, _password);

        widget.auth.sendEmailVerification();
        _showVerifyEmailSentDialog();
        print('Signed up user: $userId');
      } catch (e) {
        print('Error: $e');
        bool _undefinedError = false;

        switch (e.code) {
          case "ERROR_INVALID_EMAIL":
            _errorMessage = "* Ogiltlig formattering av e-postadress.";
            break;
          case "ERROR_EMAIL_ALREADY_IN_USE":
            _errorMessage = "* E-postadressen används redan.";
            break;
          default:
            _undefinedError = true;
            _errorMessage = "* Ett oväntat fel inträffade.";
        }

        setState(() {
          if (_undefinedError) _formKey.currentState.reset();
        });
      }
    }
  }

  Widget showInputField(String inputField) {
    return Container(
      padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1.2, bottom: SizeConfig.blockSizeVertical * 1.5),
      child: TextFormField(
          maxLines: 1,
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          obscureText: inputField.toLowerCase().contains("lösenord"),
          decoration: new InputDecoration(
            hintText: '$inputField',
            border: OutlineInputBorder(),
          ),
          validator: (valueOfInputField) =>
              setValidationOfInputField(inputField, valueOfInputField),
          onSaved: (String valueOfInputField) {
            switch (inputField) {
              case "E-postadress": _email = valueOfInputField.trim(); break;
              case "Lösenord": _password = valueOfInputField.trim(); break;
              case "Bekräfta e-postadress": _confirmEmail = valueOfInputField.trim(); break;
              case "Bekräfta lösenord": _confirmPassword = valueOfInputField.trim(); break;
              default:
                print(" ERROR");
                break; //TODO: catch error
            }
          }),
    );
  }

  String setValidationOfInputField(String inputField, String valueOfInputField) {
    switch (inputField) {
      case "E-postadress":
        return valueOfInputField.isEmpty ? "*Obligatoriskt fält" : null;
      case "Lösenord":
        return valueOfInputField.isEmpty
            ? "*Obligatoriskt fält"
            : (valueOfInputField.length < 6
                ? "Lösenordet måste bestå av minst 6st tecken"
                : null);
      case "Bekräfta e-postadress":
        return valueOfInputField.isEmpty
            ? "*Obligatoriskt fält"
            : (valueOfInputField != _email
                ? "E-postadressen stämmer ej med ovan"
                : null);
      case "Bekräfta lösenord":
        return valueOfInputField.isEmpty
            ? "*Obligatoriskt fält"
            : (valueOfInputField.length < 6
                ? "Lösenordet måste bestå av minst 6st tecken"
                : (valueOfInputField != _password
                    ? "Lösenordet stämmer ej med ovan"
                    : null));
      default:
        print("CATCH ERROR");
        return null;
        break; //TODO: catch error
    }
  }

  Widget showTermsAndConditionsRow() {
    return Container(
      child:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Flexible(child: showChechBox()),
        Flexible(child: Text("Jag godkänner ")),
        Flexible(child: showVillkorBtn()),
      ]),
    );
  }

  Widget showChechBox() {
    return Checkbox(
      value: _termsAndConditionsAgreement,
      onChanged: (bool value) {
        setState(() {
          _termsAndConditionsAgreement = value;
        });
      },
    );
  }

  Widget showVillkorBtn() {
    return FlatButton(
      textColor: Colors.orangeAccent,
      child: Text(
        'Villkoren',
        style: TextStyle(
          fontSize: 15,
          decoration: TextDecoration.underline,
        ),
      ),
      onPressed: () {
        _showTermsAndConditionsDialog();
      },
    );
  }

  Widget showSignUpBtn() {
    return Container(
        padding: EdgeInsets.only(left: 90, right: 90),
        child: RaisedButton(
          textColor: Colors.black,
          color: Colors.orangeAccent,
          child: Text('Registrera'),
          onPressed: validateAndSubmit,
        ));
  }

    Widget showTermsAndConditionWarning() {
    if (!_termsAndConditionsAgreement && _signUpBtnHasBeenPressed) {
      return new Container(
        alignment: Alignment.topCenter,
        child: Text(
          "* Villkoren måste godkännas",
          style: TextStyle(color: Colors.red,),
        ),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verifiera ditt konto"),
          content: new Text(
              "En länk för att verifiera ditt konto har skickats till den angivna e-postadressen."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Okej"),
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

  void _showTermsAndConditionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Villkor"),
          content: new Text("Genom att godkänna villkoren samtycker du till att vi på PVT-Parking sparar din angivna e-mail under tiden då projektet är aktivt."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Stäng"),
              onPressed: () {
                toggleFormMode();
                Navigator.of(context).pop();
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
