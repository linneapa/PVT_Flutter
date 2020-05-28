import 'package:ezsgame/pages/login_sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test/test.dart';
import 'package:ezsgame/firebase/authentication.dart';
import 'package:mockito/mockito.dart';

class FirebaseAuthMock extends Mock implements FirebaseAuth{}
class FirebaseUserMock extends Mock implements FirebaseUser{}
class GoogleSignInMock extends Mock implements GoogleSignIn{}
class GoogleSignInAccountMock extends Mock implements GoogleSignInAccount{}
class GoogleSignInAuthenticationMock extends Mock implements GoogleSignInAuthentication{}

class AuthMock extends Mock implements Auth{}


void main() {
//  group('Auth', () {
//    final FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
//    final GoogleSignInMock googleSignInMock = GoogleSignInMock();
    final FirebaseUserMock firebaseUserMock = FirebaseUserMock();
//    final GoogleSignInAccountMock googleSignInAccountMock =
//        GoogleSignInAccountMock();
//    final GoogleSignInAuthenticationMock googleSignInAuthenticationMock =
//        GoogleSignInAuthenticationMock();
    final auth = AuthMock();
    final LoginSignupPage loginSignupPage = LoginSignupPage();

    test('signIn returns a firebaseUser.uid', () async {

      when(firebaseUserMock.uid).thenAnswer((_) => 'email');

      when(await auth.signIn('email', 'password')).thenAnswer((_) => firebaseUserMock.uid);

      expect(auth.signIn('email', 'password'), firebaseUserMock.uid);
    });

//    test('signInWithGoogle returns a user', () async {
//      when(googleSignInMock.signIn()).thenAnswer((_) =>
//          Future<GoogleSignInAccountMock>.value(googleSignInAccountMock));
//
//      when(googleSignInAccountMock.authentication).thenAnswer((_) =>
//          Future<GoogleSignInAuthenticationMock>.value(
//              googleSignInAuthenticationMock));
//
//      when(firebaseAuthMock.signInWithGoogle(
//        idToken: googleSignInAuthenticationMock.idToken,
//        accessToken: googleSignInAuthenticationMock.accessToken,
//      )).thenAnswer((_) => Future<FirebaseUserMock>.value(firebaseUserMock));
//
//      expect(await auth.signInWithGoogle(), firebaseUserMock);
//
//      verify(googleSignInMock.signIn()).called(1);
//      verify(googleSignInAccountMock.authentication).called(1);
//      verify(firebaseAuthMock.signInWithGoogle(
//        idToken: googleSignInAuthenticationMock.idToken,
//        accessToken: googleSignInAuthenticationMock.accessToken,
//      )).called(1);
//    });
//  });
}
