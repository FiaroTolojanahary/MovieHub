import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

// google_sign_in 7 : GoogleSignIn() devient le singleton GoogleSignIn.instance,
// qui doit être initialisé UNE fois avant tout autre appel.
bool _googleInitialized = false;

Future<void> _ensureGoogleSignIn() async {
  if (_googleInitialized) return;
  await GoogleSignIn.instance.initialize(
    // Android : si l'initialisation échoue faute de client, passer
    // serverClientId: '<ID client OAuth "Web">.apps.googleusercontent.com'
  );
  _googleInitialized = true;
}

Future<UserCredential> signInWithGoogle() async {
  if (kIsWeb) {
    // Sur le web, Firebase gère lui-même la popup Google.
    return FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
  }
  await _ensureGoogleSignIn();

  // Trigger the authentication flow
  // (7.x : authenticate() remplace signIn() et lève une
  // GoogleSignInException si l'utilisateur annule, au lieu de renvoyer null)
  final GoogleSignInAccount googleUser =
      await GoogleSignIn.instance.authenticate();

  // Obtain the auth details from the request
  // (7.x : authentication est synchrone et ne contient plus que l'idToken)
  final googleAuth = googleUser.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    idToken: googleAuth.idToken,
  );

  // Once signed in, return the UserCredential
  return FirebaseAuth.instance.signInWithCredential(credential);
}
