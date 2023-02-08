// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:itask/constants.dart';
import 'package:itask/provider/google_signin.dart';
import 'package:itask/screens/screen_handler.dart';
import 'package:itask/screens/login_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSigninProvider(),
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: kprimaryColor,
          appBarTheme: AppBarTheme(color: kprimaryColor),
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: kprimaryColor,
        ),
        debugShowCheckedModeBanner: false,
        home: ScreenHandler(),
      ),
    );
  }
}
