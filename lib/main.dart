import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login_v2/LoginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(); 
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key}); // Se agrega el parámetro key

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Se usa MaterialApp en lugar de Material
      title: "FirebaseApp",
      home: Loginpage(),
    );
  }
}
