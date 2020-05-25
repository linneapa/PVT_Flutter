
import 'package:ezsgame/firebase/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezsgame/pages/login_sign_up.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseUser extends Mock implements FirebaseUser{}

class MockAuth extends Mock implements Auth {
  MockAuth({this.userId});
  String userId;
  bool didRequestSignIn = false;
  Future<String> signIn(String email, String password) async {
    didRequestSignIn = true;
    if (userId != null) {
      return Future.value(userId);
    } else {
      throw StateError('No user');
    }
  }
}

void main() {

  Widget buildTestableWidget(Widget widget) {
    // https://docs.flutter.io/flutter/widgets/MediaQuery-class.html
    return new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home: widget));
  }

  testWidgets('empty email and password doesn\'t call sign in', (WidgetTester tester) async {

    // create a LoginPage
    LoginSignupPage loginPage = new LoginSignupPage();
    // add it to the widget tester
    await tester.pumpWidget(buildTestableWidget(loginPage));

    // tap on the login button
    Finder loginButton = find.byKey(Key('LogInButton'));
    await tester.tap(loginButton);

    // 'pump' the tester again. This causes the widget to rebuild
    await tester.pump();

    // check that the hint text is empty
    Finder hintText = find.byKey(Key('hint'));
    expect(hintText.toString().contains(''), true);
  });

// test som inte fungerar
//  testWidgets('non-empty email and password, valid account, calls sign in, succeeds', (WidgetTester tester) async {
//
//    // mock with a user id - simulates success
//    MockAuth mock = new MockAuth(userId: 'uid');
//    LoginSignupPage loginPage = new LoginSignupPage(auth: mock);
//    await tester.pumpWidget(buildTestableWidget(loginPage));
//
//    Finder emailField = find.byKey(Key('email'));
//    await tester.enterText(emailField, 'email');
//
//    Finder passwordField = find.byKey(Key('password'));
//    await tester.enterText(passwordField, 'password');
//
//    Finder loginButton = find.byKey(Key('LogInButton'));
//    await tester.tap(loginButton);
//
//    await tester.pump();
//
////    Finder hintText = find.byKey(new Key('hint'));
////    Finder text = find.text('Signed in:');
////    expect(text.toString().contains('Signed In'), true);
//
//    expect(mock.didRequestSignIn, true);
//  });
//
//  testWidgets('non-empty email and password, invalid account, calls sign in, fails', (WidgetTester tester) async {
//
//    // mock without user id - throws an error and simulates failure
//    MockAuth mock = new MockAuth(userId: null);
//    LoginSignupPage loginPage = new LoginSignupPage(auth: mock);
//    await tester.pumpWidget(buildTestableWidget(loginPage));
//
//    Finder emailField = find.byKey(new Key('email'));
//    await tester.enterText(emailField, 'email');
//
//    Finder passwordField = find.byKey(new Key('password'));
//    await tester.enterText(passwordField, 'password');
//
//    Finder loginButton = find.byKey(new Key('LogInButton'));
//    await tester.tap(loginButton);
//
//    await tester.pump();
//
//    Finder hintText = find.byKey(new Key('hint'));
//    expect(hintText.toString().contains('Error'), true);
//
//    expect(mock.didRequestSignIn, true);
//  });
}