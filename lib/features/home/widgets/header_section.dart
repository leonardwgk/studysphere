import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Avatar dan Teks Sapaan
        Row(
          children: [
            // Avatar (Gunakan CircleAvatar)
            const CircleAvatar(
              radius: 25,
              // backgroundImage: NetworkImage(
              //   "https://via.placeholder.com/150",
              // ), // Ganti dengan URL gambar
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  'Hello,',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  // Ambil data dari Firebase nanti
                  'John Doe',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        // Ikon Notifikasi (Bell)
        const Icon(Icons.notifications_none, size: 30),
      ],
    );
  }
}
