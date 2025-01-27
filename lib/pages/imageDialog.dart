import 'package:flutter/material.dart';

class ImageDialog extends StatelessWidget {
  Image img;
  String name;
  ImageDialog(this.img, this.name);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 168, 168, 168),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 100, right: 20, left: 20, bottom: 20),
            child: img,
          ),
          Text(name)
        ],
      ),
    );
  }
}
