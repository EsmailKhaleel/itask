// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:itask/screens/storage/FirebaseApi.dart';
import 'package:path/path.dart' as path;

import '../../constants.dart';

class MyStorage extends StatefulWidget {
  const MyStorage({Key? key}) : super(key: key);

  @override
  State<MyStorage> createState() => _MyStorageState();
}

class _MyStorageState extends State<MyStorage> {
  File? file;
  UploadTask? task;

  @override
  Widget build(BuildContext context) {
    final fileName =
        file != null ? path.basename(file!.path) : "No file Selected";
    return Scaffold(
      appBar: AppBar(title: Text("Firebase Upload"), centerTitle: true),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            height: 50,
            width: 300,
            color: kprimaryColor.withAlpha(120),
            child: TextButton.icon(
              onPressed: () {
                selectFile();
              },
              icon: Icon(Icons.attach_file),
              label: Text(
                "Select File",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            fileName,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            height: 50,
            width: 300,
            color: kprimaryColor.withAlpha(120),
            child: TextButton.icon(
              onPressed: () {
                uploadFile();
              },
              icon: Icon(Icons.cloud_upload_outlined),
              label: Text(
                "Upload File",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          task != null ? buildupLoadStatus(task!) : CircularProgressIndicator(),
        ]),
      ),
    );
  }

  selectFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      final path = result.files.single.path!;
      setState(() {
        file = File(path);
      });
    } else {
      print('error');
    }
  }

  uploadFile() async {
    if (file == null) return;
    final fileName = path.basename(file!.path);
    final destination = "files/$fileName";
    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});
    if (task == null) return;
    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print("Download link : " + urlDownload);
  }

  Widget buildupLoadStatus(UploadTask task) {
    return StreamBuilder<TaskSnapshot>(
      stream: task.snapshotEvents,
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          final snap = snapshot.data;
          final progress = (snap!.bytesTransferred / snap.totalBytes);
          final precentage = (progress * 100).toStringAsFixed(2);
          return Text(
            "$precentage %",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          );
        } else {
          return Container();
        }
      }),
    );
  }
}
