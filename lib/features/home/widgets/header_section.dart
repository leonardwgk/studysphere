import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/auth/providers/user_provider.dart';

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
              children: <Widget>[
                const Text(
                  'Hello,',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    if (userProvider.isLoading) {
                      return const SizedBox(
                        width: 100,
                        height: 20,
                        child: LinearProgressIndicator(),
                      );
                    }
                    return Text(
                      userProvider.username ?? 'User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
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
