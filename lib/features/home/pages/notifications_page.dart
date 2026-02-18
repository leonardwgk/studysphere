import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studysphere_app/features/friend/pages/friend_profile_page.dart';
import 'package:studysphere_app/features/home/pages/post_detail_page.dart';
import 'package:studysphere_app/features/home/services/social_notification_service.dart';
import 'package:studysphere_app/shared/models/notification_model.dart';
import 'package:studysphere_app/shared/widgets/custom_avatar.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final SocialNotificationService _service = SocialNotificationService();

  @override
  void initState() {
    super.initState();
    // Mark all as read when opening the page
    _service.markAllAsRead();
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(dt);
  }

  void _onTap(BuildContext context, NotificationModel notif) {
    // Mark individual notification as read (already done at page-open, but safety)
    _service.markAsRead(notif.id);

    if (notif.type == NotificationType.follow) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FriendProfilePage(userId: notif.senderId),
        ),
      );
    } else if (notif.type == NotificationType.post &&
        notif.postId != null &&
        notif.postId!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PostDetailPage(postId: notif.postId!),
        ),
      );
    }
  }

  Widget _buildNotifTile(
    BuildContext context,
    NotificationModel notif,
  ) {
    final String description = notif.type == NotificationType.follow
        ? 'started following you.'
        : 'posted a new study session: "${notif.postTitle ?? ''}"';

    return Material(
      color: notif.isRead ? Colors.white : Colors.blue.shade50,
      child: InkWell(
        onTap: () => _onTap(context, notif),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CustomAvatar(
                photoUrl: notif.senderPhotoUrl,
                name: notif.senderUsername,
                radius: 24,
              ),
              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: notif.senderUsername,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: ' $description'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(notif.createdAt),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Unread dot
              if (!notif.isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _service.getNotificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load notifications.',
                style: TextStyle(color: Colors.grey[500]),
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No notifications yet.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
            itemBuilder: (context, index) =>
                _buildNotifTile(context, notifications[index]),
          );
        },
      ),
    );
  }
}
