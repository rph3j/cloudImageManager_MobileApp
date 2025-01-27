import 'package:flutter/material.dart';
import 'package:mobile_app/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Test App",
      home: HomePage(),
    );
  }
}
