import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:studysphere_app/firebase_options.dart';
import 'package:studysphere_app/features/auth/pages/auth_gate.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/auth/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ), // Passing user state untuk data sharing antar widgets
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'StudySphere',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F7F9),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),

        home: const AuthGate(),
      ),
    );
  }
}
