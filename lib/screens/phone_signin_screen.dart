// ignore_for_file: prefer_const_constructors, prefer_function_declarations_over_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../constants.dart';

class PhoneSigninScreen extends StatefulWidget {
  PhoneSigninScreen({Key? key}) : super(key: key);

  @override
  State<PhoneSigninScreen> createState() => _PhoneSigninScreenState();
}

class _PhoneSigninScreenState extends State<PhoneSigninScreen> {
  PhoneNumber? _phoneNumber;

  String? _message;

  String? _verificationId;

  bool isSMSsent = false;

  final auth = FirebaseAuth.instance;

  final TextEditingController smsController = TextEditingController();
  final _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Sign-in"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: InternationalPhoneNumberInput(
                onInputChanged: (phoneNumber) {
                  _phoneNumber = phoneNumber;
                },
                inputBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            isSMSsent
                ? Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      controller: smsController,
                      decoration: InputDecoration(
                        hintText: "OTP Here",
                        labelText: "OTP",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  )
                : Container(),
            !isSMSsent
                ? Container(
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
                        setState(() {
                          isSMSsent = true;
                        });
                        _VerfiyPhone();
                      },
                      child: Text(
                        "Send OTP",
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                : Container(
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
                        _signinWithPhoneNumber();
                      },
                      child: Text(
                        "Verify OTP",
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _VerfiyPhone() async {
    setState(() {
      _message = '';
    });
    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      setState(() {
        _message = "Received phone auth credential =$credential";
      });
      await auth.signInWithCredential(credential);
    };
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      setState(() {
        _message =
            "Phone number verification failed ,code:${e.code},message:${e.message}";
      });
    };
    final PhoneCodeSent codeSent =
        (String verificationId, int? resendToken) async {
      _verificationId = verificationId;
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };
    await auth.verifyPhoneNumber(
      phoneNumber: _phoneNumber!.phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  _signinWithPhoneNumber() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsController.text,
    );
    final user = (await auth.signInWithCredential(credential)).user;
    final currentUser = auth.currentUser;
    assert(user!.uid == currentUser!.uid);
    if (user != null) {
      _db.collection("users").doc(user.uid).set({
        "phonenumber": user.phoneNumber,
        "lastseen": DateTime.now(),
      });
      _message = "Success signin ,user id is: " + user.uid;
      print(_message);
    } else {
      _message = "Sign in failed";
    }
  }
}
