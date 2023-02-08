// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:itask/constants.dart';
import 'package:itask/provider/google_signin.dart';
import 'package:itask/screens/email_pass_signup.dart';
import 'package:itask/screens/phone_signin_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  var _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    decoration: BoxDecoration(boxShadow: const [
                      BoxShadow(
                          blurRadius: 20,
                          color: Color(0x4400F58D),
                          offset: Offset(10, 10),
                          spreadRadius: 0),
                    ]),
                    height: 200,
                    width: 200,
                    child: Image.asset(
                      "assets/logo_round.png",
                      height: 180,
                      width: 180,
                    )),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
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
                      signIn();
                    },
                    child: Text(
                      "Login With Email",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EmailPassSignupScreen()));
                  },
                  child: Text(
                    "Sign-up With Email",
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PhoneSigninScreen()));
                        },
                        icon: Icon(
                          Icons.phone,
                          size: 22,
                          color: Colors.blue,
                        ),
                        label: Text(
                          "Sign-in using phone",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          final provider = Provider.of<GoogleSigninProvider>(
                              context,
                              listen: false);
                          provider.signinWithGoogle(context);
                        },
                        icon: Icon(FontAwesomeIcons.google,
                            size: 22, color: Colors.red),
                        label: Text(
                          "Sign in using Gmail",
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signIn() async {
    String email = emailController.text;
    String password = passwordController.text;
    if (email.isNotEmpty && password.isNotEmpty) {
      _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        print(value.user!.email);
        print(value.user!.providerData);
        final user = _auth.currentUser;
        _db.collection("users").doc(value.user!.uid).set({
          "email": value.user!.email,
          "lastseen": DateTime.now(),
        
        }).catchError((e) {
          print(e.toString());
        });
        final snackBar = SnackBar(
          content: const Text('Sign in Success'),
          action: SnackBarAction(
            label: 'ok',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }).catchError((e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  title: Text("Error"),
                  content: Text(e.toString()),
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
