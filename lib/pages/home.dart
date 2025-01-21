import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  SingleChildScrollView Gallery() {
    return SingleChildScrollView(
        child: Column(children: [
      Container(
        margin: EdgeInsets.only(top: 40, left: 20, right: 20),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 48, 48, 48),
            blurRadius: 40,
            spreadRadius: 0.0,
          )
        ]),
        //==================================================================
        //             Pasek do wyszukiwania - na razie nie dizał
        //==================================================================
        child: TextField(
          onChanged: onQueryChanged,
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
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
      ListView.builder(
          scrollDirection: Axis.vertical,
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemCount: resultMap.length,
          itemBuilder: (context, i) {
            String key = resultMap.keys.elementAt(i);
            return Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  border: Border.all(width: 5, color: Colors.amber),
                  borderRadius: BorderRadius.all(Radius.circular(
                          10.0) //                 <--- border radius here
                      ),
                ),
                child: Column(
                  children: [
                    Container(
                        color: Colors.black,
                        width: 500,
                        height: 350,
                        child: resultMap[key]),
                    Text(key)
                  ],
                ));
          })
    ]));
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
      title: Text("Przegląd zdięć"),
      backgroundColor: Colors.amber,
      centerTitle: true,
      // w appBar ikonka po lewej
      leading: GestureDetector(
        onTap: () {},
        child: Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: const Color.fromARGB(0, 255, 193, 7),
              borderRadius:
                  BorderRadius.circular(10)), // aby działało położenie ikonki
          child: SvgPicture.asset(
            "assets/icons/back arrow.svg",
            width: 20,
            height: 20,
          ),
        ),
      ),
      // ikonki po porawej
      actions: [
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color.fromARGB(0, 255, 193, 7),
                borderRadius:
                    BorderRadius.circular(10)), // aby działało położenie ikonki
            child: SvgPicture.asset(
              "assets/icons/hamburger.svg",
              width: 20,
              height: 20,
            ),
          ),
        ),
      ],
    );
  }
}
