import 'package:ezsgame/firebase/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'dart:async';

class FirebaseAuthMock extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements FirebaseUser {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockAuth extends Mock implements Auth {}

//class MockAuth extends Mock implements Auth {
//  MockFirebaseAuth mockFirebaseAuth;
//  MockGoogleSignIn mockGoogleSignIn;
//  MockAuth({this.mockFirebaseAuth});
//  String uid;
//  bool didRequestSignIn = false;
//  Future<String> signIn(String email, String password) async {
//    didRequestSignIn = true;
//    if (uid != null) {
//      return Future.value(uid);
//    } else {
//      return null;
//    }
//  }
//}

void main() {
  group('login tests', () {
    final FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
    final MockGoogleSignIn googleSignInMock = MockGoogleSignIn();
    final MockFirebaseUser firebaseUserMock = MockFirebaseUser();
    final MockGoogleSignInAccount googleSignInAccountMock = MockGoogleSignInAccount();
    final MockGoogleSignInAuthentication googleSignInAuthenticationMock = MockGoogleSignInAuthentication();
    final MockAuth mockAuth = MockAuth();

    test('signInWithGoogle returns a user', () async {
      when(googleSignInMock.signIn()).thenAnswer((_) =>
      Future<MockGoogleSignInAccount>.value(googleSignInAccountMock));

      when(googleSignInAccountMock.authentication).thenAnswer((_) =>
      Future<MockGoogleSignInAuthentication>.value(
          googleSignInAuthenticationMock));

      when(mockAuth.getCurrentUser()).thenAnswer((_) => Future<MockFirebaseUser>.value(firebaseUserMock));

      when(mockAuth.signInWithGoogle()).thenAnswer((_) => Future<String>.value(firebaseUserMock.uid));
      //testar vad?
      //when(mockAuth.signInWithGoogle()).thenAnswer((_) => Future<MockFirebaseUser>.value(firebaseUserMock).then((firebaseUserMock) => firebaseUserMock.uid));

      expect(await mockAuth.getCurrentUser(), firebaseUserMock);
      expect(await mockAuth.signInWithGoogle(), firebaseUserMock.uid);
    });
  });
}
