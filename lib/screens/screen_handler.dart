// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:itask/provider/google_signin.dart';
import 'package:itask/screens/email_pass_signup.dart';
import 'package:itask/screens/home_page_screen.dart';
import 'package:itask/screens/login_screen.dart';
import 'package:provider/provider.dart';

class ScreenHandler extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return HomePageScreen();
          } else if (snapshot.hasError) {
            return Center(child: Text("There is some error"));
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
