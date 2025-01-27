import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app/pages/imageDialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  // tak wiem że taki coś najlepiej w osobnym pliku trzymać ;P
  String path = "gs://cloudimagemanager.firebasestorage.app/";
  //late Future<List<Image>> items;
  //late Future<List<Image>> searchResults;
  late Future<Image> picture;
  Map<String, Image> imageMap = {};
  Map<String, Image> resultMap = {};

  List<String> imgNames = [];
  @override
  void initState() {
    super.initState();
    getImgMap();
    //items = getList2();
    //searchResults = items;
    picture = getImg();
    String query = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar(), body: Gallery());
  }

//==================================================================
//                        Gasleria
//==================================================================
  Container Gallery() {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.blueAccent],
        )),
        height: double.infinity,
        child: SingleChildScrollView(
            child: Column(children: [
          Container(
            margin: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 48, 48, 48),
                blurRadius: 20,
                spreadRadius: 3.0,
              )
            ]),
            //==================================================================
            //             Pasek do wyszukiwania
            //==================================================================
            child: TextField(
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  contentPadding: EdgeInsets.all(15),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(22),
                    child: SvgPicture.asset(
                      "assets/icons/search.svg",
                      width: 20,
                      height: 20,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  )),
            ),
          ),
          //==================================================================
          //               Wczytanie pojedyńczego zdjęcia
          //==================================================================
          /*FutureBuilder<Image>(
          builder: (context, snapshot) {
            // Połączenie REST API w takcie obsługi
            if (snapshot.connectionState == ConnectionState.active &&
                !snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            // Połączenie zakończone błędem
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasError) {
              return Center(child: Text("Error in fetching!"));
            }

            // Uzyskano właściwe rezultaty
            return Container(
              padding: EdgeInsets.all(20),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.blueAccent)),
              child: snapshot.data,
            );
          },
          future: picture,
        ),*/
          //==================================================================
          //               Wczytanie całej listy zdjęcia
          //==================================================================
          GridView.builder(
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // number of items in each row
                mainAxisSpacing: 8.0, // spacing between rows
                crossAxisSpacing: 8.0, // spacing between columns
              ),
              padding: EdgeInsets.all(8.0),
              shrinkWrap: true,
              itemCount: resultMap.length,
              itemBuilder: (context, i) {
                String key = resultMap.keys.elementAt(i);
                return Container(
                    child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 168, 168, 168),
                        borderRadius: BorderRadius.all(Radius.circular(60))),
                    child: Container(
                        margin: EdgeInsets.all(10), child: resultMap[key]),
                  ),
                  onTap: () async {
                    await showDialog(
                        context: context,
                        builder: (_) => ImageDialog(resultMap[key]!, key));
                  },
                ));
              })
        ])));
  }

//==================================================================
//             Jedno zdięcie -> do wcześniejszych testów
//==================================================================

  Future<Image> getImg() async {
    final ref = FirebaseStorage.instance.refFromURL(
        'gs://cloudimagemanager.firebasestorage.app/landsat_images/LC09_195028_20221129.png');
    var url = await ref.getDownloadURL();
    return Image.network(url);
  }

//==================================================================
//                      Lista zdięć
//==================================================================
  void getImgMap() async {
    ListResult resNames = await FirebaseStorage.instance
        .refFromURL("gs://cloudimagemanager.firebasestorage.app/landsat_images")
        .listAll();
    List<String> names = [];
    for (var resName in resNames.items) {
      String name = resName.fullPath.toString().substring(15);
      names.add(name);
    }

    List<Image> items = [];
    var res = await http.post(
      Uri.parse('https://get-scaled-images-43zelk7nya-uc.a.run.app'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{}),
    );
    debugPrint(res.body);
    Map<String, dynamic> map = {};
    if (res.statusCode == 200) {
      map = jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load images');
    }
    for (String img in map["scaled_images"]) {
      Uint8List bytes = base64Decode(img);
      items.add(Image.memory(bytes));
    }
    final Map<String, Image> imgMap = {};
    if (items.length == names.length) {
      for (var i = 0; i < names.length; i++) {
        imgMap[names[i]] = items[i];
      }
    }
    setState(() {
      imageMap = imgMap;
      resultMap = imgMap;
    });
  }

//==================================================================
//                      Wyszukiwanie
//==================================================================
  void onQueryChanged(String query) {
    if (query == "") {
      setState(() {
        resultMap = imageMap;
      });
    } else {
      final Map<String, Image> result = {};
      List<String> keys = imageMap.keys
          .toList()
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
      for (String key in keys) {
        result[key] = imageMap[key]!;
      }
      setState(() {
        resultMap = result;
      });
    }
  }

//==================================================================
//            generowanie paska ugury aplikacji
//==================================================================
  AppBar appBar() {
    return AppBar(
      title: Text("Gallery"),
      backgroundColor: Colors.blueAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      centerTitle: true,
    );
  }
}
