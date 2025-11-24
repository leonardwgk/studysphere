import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader();

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
            image: const DecorationImage(
              // Ganti dengan URL foto user dari Firebase nanti
              image: NetworkImage('https://picsum.photos/id/64/200/200'),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
        ),
        const SizedBox(width: 20),
        // Info Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '@this_is_johndoe',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatText('12', 'Following'),
                const SizedBox(width: 15),
                const Text('•', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 15),
                _buildStatText('4', 'Followers'),
              ],
            ),
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
              color: Colors.blue, // Warna biru sesuai desain
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Roboto', // Pastikan font default Flutter
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