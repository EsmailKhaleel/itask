import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseDownloadScreen extends StatefulWidget {
  const FirebaseDownloadScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseDownloadScreen> createState() => _FirebaseDownloadScreenState();
}

class _FirebaseDownloadScreenState extends State<FirebaseDownloadScreen> {
  late Future<ListResult> futureFiles;
  Map<int, double> downloadProgress = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureFiles = FirebaseStorage.instance.ref('/files').listAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download Files"),
      ),
      body: FutureBuilder<ListResult>(
        future: futureFiles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final files = snapshot.data!.items;
            return ListView.builder(
              itemCount: files.length,
              itemBuilder: ((context, index) {
                final file = files[index];
                double? progress = downloadProgress[index];
                return ListTile(
                  title: Text(file.name),
                  subtitle: progress != null
                      ? LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.black,
                        )
                      : null,
                  trailing: IconButton(
                    onPressed: () {
                      downloadFile(index, file);
                    },
                    icon: Icon(Icons.download),
                  ),
                );
              }),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("error"));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future downloadFile(int index, Reference ref) async {
    //in app directory(not visible to user)
    // final dir = await getApplicationDocumentsDirectory();
    // final file = File('${dir.path}/${ref.name}');
    // await ref.writeToFile(file);
//-----------------------------------------------------------------
    //in gallery directory( visible to user)
    final url = await ref.getDownloadURL();
    final tempdir = await getTemporaryDirectory();
    final path = '${tempdir.path}/${ref.name}';
    await Dio().download(
      url,
      path,
      onReceiveProgress: (count, total) {
        double progress = count / total;
        setState(() {
          downloadProgress[index] = progress;
        });
      },
    );
    if (url.contains('.mp4')) {
      await GallerySaver.saveVideo(path, toDcim: true);
    } else if (url.contains('.jpg')) {
      await GallerySaver.saveImage(path, toDcim: true);
    } else if (url.contains('.jpeg')) {
      await GallerySaver.saveImage(path, toDcim: true);
    } else if (url.contains('.png')) {
      await GallerySaver.saveImage(path, toDcim: true);
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Downloaded " + ref.name)));
  }
}
