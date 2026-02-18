import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/auth/providers/user_provider.dart';
import 'package:studysphere_app/features/home/pages/notifications_page.dart';
import 'package:studysphere_app/features/home/services/social_notification_service.dart';
import 'package:studysphere_app/shared/widgets/custom_avatar.dart';

class HeaderSection extends StatelessWidget {
  HeaderSection({super.key});

  final SocialNotificationService _notifService = SocialNotificationService();

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
        StreamBuilder<int>(
          stream: _notifService.getUnreadCountStream(),
          builder: (context, snapshot) {
            final unreadCount = snapshot.data ?? 0;
            return Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(fontSize: 10),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_none, size: 30),
              ),
            );
          },
        ),
      ],
    );
  }
}
