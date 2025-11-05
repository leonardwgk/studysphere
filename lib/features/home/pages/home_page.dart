import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: const Text("StudyShpere Home"),
        actions: [
          // tombol logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // panggil service logout
              await authService.signOut();
            },
          )
        ],
      ),
      body: const Center(
        child: Text("Selamat datang di StudySphere!"),
      ),
    );
  }
}