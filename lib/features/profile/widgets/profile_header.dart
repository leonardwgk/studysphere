import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/data/models/user_model.dart'; // Import model

class ProfileHeader extends StatelessWidget {
  final UserModel user; // 1. Tambahkan variabel ini

  // 2. Wajibkan parameter user saat dipanggil
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200, width: 1),
            image: user.photoUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(user.photoUrl),
                    fit: BoxFit.cover,
                  )
                : null, // kalau kosong, jangan pakai image
            ),
            child: user.photoUrl.isEmpty
                ? Center(
                    child: Text(
                      user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  )
                : null,
        ),

        const SizedBox(width: 20),
        // Info Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // nama dari firebase
            Text(
              user.username, 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                // Following
                GestureDetector(
                  onTap: () {
                    print("Following tapped");
                  },
                  child: _buildStatText(user.followingCount.toString(), 'Following'),
                ),

                const SizedBox(width: 15),
                const Text('•', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 15),

                // Followers
                GestureDetector(
                  onTap: () {
                    print("Followers tapped");
                  },
                  child: _buildStatText(user.followersCount.toString(), 'Followers'),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildStatText(String count, String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$count ',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Roboto',
            ),
          ),
          TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 14,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}