import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/pages/login_page.dart';
import 'package:studysphere_app/features/home/pages/home_gate.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/auth/providers/user_provider.dart';
import 'package:studysphere_app/features/calender/providers/calendar_provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to the Firebase Auth Stream directly
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. If waiting for connection
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. If we have a user -> Go to Home
        if (snapshot.hasData) {
          final userId = snapshot.data!.uid;

          // Fetch user data and preload calendar data when logged in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // --- PERBAIKAN DI SINI ---
            // Ganti fetchUser(userId) menjadi initUserStream()
            // Kita panggil ini untuk memastikan stream nyala saat login berhasil
            Provider.of<UserProvider>(context, listen: false).initUserStream();

            // CalendarProvider biarkan tetap seperti ini (asumsi logic-nya belum diubah)
            Provider.of<CalendarProvider>(
              context,
              listen: false,
            ).loadHomeData(userId);
          });

          return const HomeGate();
        }

        // 3. If no user -> Go to Login
        return const LoginPage();
      },
    );
  }
}
