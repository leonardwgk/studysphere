import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:studysphere_app/shared/models/user_model.dart';
import 'package:studysphere_app/features/profile/pages/edit_profile_page.dart';

class ActionButtons extends StatelessWidget {
  final UserModel user;

  const ActionButtons({super.key, required this.user});

  void _shareProfile() {
    final String message =
        'Check out my StudySphere profile!\n\n'
        '👤 ${user.username}\n'
        '📚 Join me on StudySphere — Focus Deeply. Connect Socially. Grow Daily.';
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Edit Profile
        Expanded(
          child: ElevatedButton(
            onPressed: () {
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
            onPressed: _shareProfile,
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
      ],
    );
  }
}
