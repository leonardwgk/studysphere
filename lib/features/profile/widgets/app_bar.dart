import 'package:flutter/material.dart';
import 'package:studysphere_app/features/profile/pages/settings_page.dart';

class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, // Samakan dengan background ProfilePage
      elevation: 0, // Hilangkan bayangan agar menyatu
      automaticallyImplyLeading: false, // Hapus tombol back otomatis
      centerTitle: false, // Judul rata kiri
      title: const Padding(
        padding: EdgeInsets.only(left: 8.0), // Sedikit padding biar ga mepet
        child: Text(
          'Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
          icon: const Icon(Icons.menu, size: 30, color: Colors.black),
        ),
        const SizedBox(width: 10), // Jarak kanan
      ],
    );
  }
}
