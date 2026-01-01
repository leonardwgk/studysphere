import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/auth/providers/user_provider.dart';
import 'package:studysphere_app/shared/widgets/custom_avatar.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return CustomAvatar(
                  photoUrl: userProvider.user?.photoUrl,
                  name: userProvider.user?.username ?? 'U',
                  radius: 25,
                );
              },
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello, ',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    if (userProvider.isLoading) {
                      return const SizedBox(
                        width: 100,
                        height: 4, // Lebih tipis agar rapi
                        child: LinearProgressIndicator(),
                      );
                    }
                    return Text(
                      userProvider.user?.username ?? 'User',
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
        IconButton(
          onPressed: () {
            // Logika notifikasi nanti
          },
          icon: const Icon(Icons.notifications_none, size: 30),
        ),
      ],
    );
  }
}
