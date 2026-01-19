import 'package:flutter/material.dart';
import 'package:studysphere_app/shared/models/user_model.dart';
import 'package:studysphere_app/features/profile/pages/follow_list_page.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar Section
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
                : null,
          ),
          child: user.photoUrl.isEmpty
              ? Center(
                  child: Text(
                    user.username.isNotEmpty
                        ? user.username[0].toUpperCase()
                        : 'U',
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
            // Nama User
            Text(
              user.username,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            
            // Row Stats (Following & Followers)
            Row(
              children: [
                // 1. Tombol FOLLOWING
                GestureDetector(
                  onTap: () {
                    // Navigasi ke Halaman List (Tab Following / Index 1)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FollowListPage(
                          userId: user.uid,
                          username: user.username,
                          initialIndex: 0, // 0 = Tab Following
                        ),
                      ),
                    );
                  },
                  child: _buildStatText(
                    user.followingCount.toString(),
                    'Following',
                  ),
                ),

                const SizedBox(width: 15),
                const Text('•', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 15),

                // 2. Tombol FOLLOWERS
                GestureDetector(
                  onTap: () {
                    // Navigasi ke Halaman List (Tab Followers / Index 0)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FollowListPage(
                          userId: user.uid,
                          username: user.username,
                          initialIndex: 1, // 1 = Tab Followers
                        ),
                      ),
                    );
                  },
                  child: _buildStatText(
                    user.followersCount.toString(),
                    'Followers',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Widget Helper untuk Text (Tetap sama)
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