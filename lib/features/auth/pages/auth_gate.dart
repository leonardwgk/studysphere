import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/pages/login_page.dart';
import 'package:studysphere_app/features/home/pages/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      // Dengerkan strean status autentikasi
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Tampilan loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Jika user sudah login, tampilkan HomePage
        if (snapshot.hasData) {
          return const HomePage();
        }
        // jika user null (belum login), tampilkan LoginPage
        return const LoginPage();
      },
    );
  }
}
