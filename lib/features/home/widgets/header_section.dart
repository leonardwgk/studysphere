import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/auth/providers/user_provider.dart';

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
                final photoUrl = userProvider.user?.photoUrl;
                return CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                  child: (photoUrl == null || photoUrl.isEmpty) ? const Icon(Icons.person, color: Colors.grey) : null,
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
                    if(userProvider.isLoading) {
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
                        fontWeight: FontWeight.bold
                      ),
                    );
                  },
                )
              ],
            )
          ],
        ),
        IconButton(
          onPressed: () {
            // Logika notifikasi nanti


          }, icon: const Icon(Icons.notifications_none, size: 30)
        )
      ],
    );
  }
}
