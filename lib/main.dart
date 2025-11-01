import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:studysphere_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudySphere',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('StudySphere Connected!'),
        ),
        body: const Center(
          child: Text('Selamat Datang di StudySphere!'),
        ),
      ),
    );
  }
}