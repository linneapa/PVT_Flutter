import 'package:ezsgame/pages/login_sign_up.dart';
import 'package:test/test.dart';

void main() {
  group('loginTextFields', () {
    test('empty email returns error string', () async {
      final error = 'Email kan inte vara tom';

      final result = EmailFieldValidator.validate('');
      expect(result, error);
    });

    test('filled out email returns null', () async {
      final result = EmailFieldValidator.validate('testmail');
      expect(result, null);
    });

    test('empty password returns error string', () async {
      final error = 'Lösenordet kan inte vara tomt';

      final result = LoginFieldValidator.validate('');
      expect(result, error);
    });

    test('filled out password returns null', () async {
      final result = LoginFieldValidator.validate('testpass');
      expect(result, null);
    });
  });
}
