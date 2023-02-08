// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itask/screens/login_screen.dart';

import '../constants.dart';

class EmailPassSignupScreen extends StatefulWidget {
  @override
  State<EmailPassSignupScreen> createState() => _EmailPassSignupScreenState();
}

class _EmailPassSignupScreenState extends State<EmailPassSignupScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Signup with Email"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Email',
                      hintText: 'Enter Your Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Password',
                      hintText: 'Enter Your Password',
                    ),
                    keyboardType: TextInputType.visiblePassword,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        kprimaryColor,
                        ksecondaryColor,
                      ]),
                      borderRadius: BorderRadius.circular(20)),
                  child: MaterialButton(
                    minWidth: 300,
                    height: 50,
                    onPressed: () {
                      signupWithEmail();
                    },
                    child: Text(
                      "Signup With Email",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text(
                    "Login With Email",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signupWithEmail() {
    String email = emailController.text;
    String password = passwordController.text;
    if (email.isNotEmpty && password.isNotEmpty) {
      _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        _db.collection("users").doc(value.user!.uid).set({
          "email":value.user!.email,
          "lastseen":DateTime.now(),
          "signin_method":value.user!.providerData
        });
        final snackBar = SnackBar(
          content: Text("Sign up with email success"),
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }).catchError((e) {
        final snackBar = SnackBar(
          content: Text(e.toString()),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: Text("Error"),
                content: Text("Please provide email and password.."),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.blue),
                      )),
                  TextButton(
                      onPressed: () {
                        emailController.text = "";
                        passwordController.text = "";
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Ok',
                        style: TextStyle(color: Colors.blue),
                      )),
                ],
              ));
    }
  }
}
