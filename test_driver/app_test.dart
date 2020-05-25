// Run "flutter drive --target=test_driver/app.dart" in terminal from project map
// Imports the Flutter Driver API.
import 'package:ezsgame/pages/login_sign_up.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('PVT map', () {
    // First, define the Finders and use them to locate widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys in step 1.
    // final counterTextFinder = find.byValueKey('counter');
    final emailField = find.byValueKey('email');
    final passwordField = find.byValueKey('password');
    final loginButton = find.byValueKey('LogInButton');

    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('login fails with incorrect email and password', () async {
      await driver.tap(emailField);
      await driver.enterText('testfail@testmail.com');
      await driver.enterText('testmail@testmail.com');
      await driver.tap(passwordField);
      await driver.enterText('test');
      await driver.enterText('testpass');
      await driver.tap(loginButton);
    });
  });
}
