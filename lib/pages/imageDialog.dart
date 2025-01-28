import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class ImageDialog extends StatefulWidget {
  Image img;
  String name;
  ImageDialog(this.img, this.name);
  @override
  State<StatefulWidget> createState() => _ImageDialog();
}

class _ImageDialog extends State<ImageDialog> {
  late Image img;
  String name = '';
  String format = '';
  String size = '';
  String date = '';
  void initState() {
    super.initState();
    getData(widget.name);
    img = widget.img;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("A tu z widoczku : $name");
    return Dialog(
      backgroundColor: const Color.fromARGB(235, 207, 207, 207),
      child: Container(
          height: 500,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 48, 48, 48),
                    blurRadius: 20,
                    spreadRadius: 2.0,
                  )
                ]),
                margin:
                    EdgeInsets.only(top: 100, right: 20, left: 20, bottom: 20),
                child: img,
              ),
              Text(name),
              Text("Size: $size"),
              Text("Type: $format"),
              Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text("Date: $date")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: Size(
                    200,
                    40,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Download'),
                onPressed: () {
                  downloadImg();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: Size(
                    200,
                    40,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Disable'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          )),
    );
  }

  Future<void> downloadImg() async {
    final ref = FirebaseStorage.instance.ref().child(
        "gs://cloudimagemanager.firebasestorage.app/landsat_images/$name.png");

    final appDocDir = await getTemporaryDirectory();
    final filePath = "${appDocDir.absolute}/images/$name.png";
    //await Gal.putImage(filePath);
    final file = File(filePath);
    debugPrint(
        filePath + "======================================================");

    final downloadTask = ref.writeToFile(file);
    downloadTask.snapshotEvents.listen((taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          debugPrint("runing +++++++++++++++++++++++++++");
          break;
        case TaskState.paused:
          debugPrint("pause////////////////////////////");
          break;
        case TaskState.success:
          debugPrint("succes =================================");
          break;
        case TaskState.canceled:
          debugPrint("cancel -------------------------------------");
          break;
        case TaskState.error:
          debugPrint("error -------------------------------------");
          break;
      }
    });
  }

  Future<void> getData(String n) async {
    var db = FirebaseFirestore.instance.collection("landsat_metadata");
    String trimName = n.substring(0, n.length - 4);
    final docRef = db.doc(trimName);
    final res = await docRef.get();
    final data = res.data() as Map<String, dynamic>;
    debugPrint('=============================================');
    debugPrint(data['id'].toString());
    name = data['id'].toString();
    format = data['type'].toString();
    size = data['properties']['system:asset_size'].toString();
    date = data['properties']['DATE_ACQUIRED'].toString();
    debugPrint("coś tokiego :$name");
    setState(() {});
  }
}
