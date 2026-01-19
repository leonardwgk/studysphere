import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:studysphere_app/firebase_options.dart';
import 'package:studysphere_app/features/auth/pages/auth_gate.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/auth/providers/user_provider.dart';
import 'package:studysphere_app/features/calender/providers/calendar_provider.dart';
import 'package:studysphere_app/features/friend/providers/friend_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
 
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  } finally {
    FlutterNativeSplash.remove();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => FriendProvider()),
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
