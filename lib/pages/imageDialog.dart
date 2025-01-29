import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

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
    format = widget.name.substring(widget.name.length - 3, widget.name.length);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("A tu z widoczku : $name");
    return Dialog(
      backgroundColor: Colors.white70,
      child: Container(
          height: 500,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(color: const Color(0xFF393D3F)),
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
                  backgroundColor: const Color(0xFF393D3F),
                  foregroundColor: const Color(0xFFC6C5B9),
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

  Future<void> getData(String n) async {
    var db = FirebaseFirestore.instance.collection("landsat_metadata");
    String trimName = n.substring(0, n.length - 4);
    final docRef = db.doc(trimName);
    final res = await docRef.get();
    final data = res.data() as Map<String, dynamic>;
    debugPrint('=============================================');
    debugPrint(data['id'].toString());
    name = data['id'].toString();
    format = data['type'].toString() + "/$format";
    double s = data['properties']['system:asset_size'] / (1024 * 1024);
    size = s.toStringAsFixed(2);
    date = data['properties']['DATE_ACQUIRED'].toString();
    debugPrint("coś tokiego :$name");
    setState(() {});
  }
}
