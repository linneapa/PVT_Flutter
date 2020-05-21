import 'dart:async';
import 'package:ezsgame/firebase/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<bool> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();

  Future<String> signInWithGoogle();

  Future<String> signInWithFacebook();

}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FacebookLogin facebookLogin = FacebookLogin();

  Future<String> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);

    FirebaseUser user = result.user;
    
    await DatabaseService(uid: user.uid).updateUserData('car', 'kungsgatan');

    if(user.isEmailVerified)
      return user.uid;

    return null;
  }

  Future<String> signUp(String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

   Future<bool> sendPasswordResetEmail(String email) async {
    if ((await _firebaseAuth.fetchSignInMethodsForEmail(email: email)).isEmpty)
      return false;  
    _firebaseAuth.sendPasswordResetEmail(email: email);
    return true;
  }

  Future<void> signOut() async {
    if (await googleSignIn.isSignedIn()) 
      await googleSignIn.signOut();
    if(await facebookLogin.isLoggedIn)
      facebookLogin.logOut();
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult =
        await _firebaseAuth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await getCurrentUser();
    assert(user.uid == currentUser.uid);
    return user.uid;
  }

    Future<String> signInWithFacebook() async {
    final FacebookLoginResult result = await facebookLogin.logIn(['email']);
  
      AuthCredential credential= FacebookAuthProvider.getCredential(accessToken: result.accessToken.token);
      AuthResult authResult = await _firebaseAuth.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await getCurrentUser();
      assert(user.uid == currentUser.uid);
      return user.uid;
  }
}
