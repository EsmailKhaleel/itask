// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:itask/constants.dart';
import 'package:itask/screens/storage/firebase_download_screen.dart';
import 'package:itask/screens/storage/firebase_upload_screen.dart';
import 'package:provider/provider.dart';

import '../provider/google_signin.dart';

class HomePageScreen extends StatefulWidget {
  HomePageScreen({Key? key}) : super(key: key);

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _taskController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Logged in"),
        actions: [
          TextButton.icon(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout),
            label: Text("Logout"),
          )
        ],
      ),
      body: StreamBuilder(
          stream: _db
              .collection("users")
              .doc(user!.uid)
              .collection("tasks")
              .orderBy("Date", descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              if (snapshot.data!.docs.isNotEmpty) {
                return ListView(
                    children: snapshot.data!.docs.map((e) {
                  return ListTile(
                    title: Text(e.get("task")),
                    tileColor: Colors.grey.shade200,
                    trailing: IconButton(
                        icon: Icon(
                          Icons.delete_rounded,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _db
                              .collection("users")
                              .doc(user!.uid)
                              .collection("tasks")
                              .doc(e.id)
                              .delete();
                        }),
                  );
                }).toList());
              } else {
                return Center(
                  child: Image.asset("assets/no_task.png"),
                );
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddTaskDialog();
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
        backgroundColor: kprimaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.person),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => FirebaseDownloadScreen())));
              },
              icon: Icon(Icons.cloud_download),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyStorage()));
              },
              icon: Icon(Icons.cloud_upload),
            ),
            IconButton(onPressed: () {}, icon: Icon(Icons.logout_outlined)),
          ],
        ),
      ),
    );
  }

  void showAddTaskDialog() {
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: Text("Add Task"),
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Task Name",
                      labelText: "Enter your task",
                      prefixIcon: Icon(FontAwesomeIcons.listCheck),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: kprimaryColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: TextButton(
                        onPressed: () {
                          String task = _taskController.text.trim();
                          _db
                              .collection("users")
                              .doc(user!.uid)
                              .collection("tasks")
                              .add({
                            "task": task,
                            "Date": DateTime.now(),
                          });
                        },
                        child: Text("Add"),
                      ),
                    ),
                  ],
                ),
              ],
            ));
  }
}
