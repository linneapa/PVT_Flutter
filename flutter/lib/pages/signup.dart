/*

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
*/
