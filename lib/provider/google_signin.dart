import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:itask/screens/screen_handler.dart';

class GoogleSigninProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;
  final _db = FirebaseFirestore.instance;

  Future signinWithGoogle(context) async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;
      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((value) {
        _db.collection("users").doc(value.user!.uid).set({
          "email": value.user!.email,
          "name": value.user!.displayName,
          "lastseen": DateTime.now(),
          "photoUrl":value.user!.photoURL,
        });

      });
    } catch (e) {
      final snackBar = SnackBar(
        content: Text(e.toString()),
        action: SnackBarAction(label: "Ok", onPressed: () {}),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print(e.toString());
    }
    notifyListeners();
  }

  Future<void> logoutGoogle() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
