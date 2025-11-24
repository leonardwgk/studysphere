import 'package:flutter/material.dart';

class ProfileTabItem extends StatelessWidget {
  const ProfileTabItem({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Menghilangkan bayangan dan membuat latar belakang transparan
      elevation: 0,
      backgroundColor: Colors.transparent,

      // Teks 'Profile' menjadi judul AppBar
      title: const Text(
        'Profile',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black, // Menjaga warna teks asli
        ),
      ),

      // IconButton masuk ke dalam daftar 'actions'
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Tambahkan logika untuk membuka menu/settings
          },
          icon: const Icon(
            Icons.menu,
            size: 30,
            color: Colors.black, // Sesuaikan warna ikon agar konsisten
          ),
        ),
      ],
    );
  }
}
