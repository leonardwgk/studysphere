import 'package:flutter/material.dart';
import 'package:studysphere_app/shared/models/user_model.dart';
import 'package:studysphere_app/features/profile/pages/edit_profile_page.dart';

class ActionButtons extends StatelessWidget {
  final UserModel user;

  const ActionButtons({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Edit Profile
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Implement edit profile logic here
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(user: user),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Share Profile
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Share Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Add Friend Icon Button
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
