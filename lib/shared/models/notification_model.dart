import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of in-app notifications
class NotificationType {
  static const String follow = 'follow';
  static const String post = 'post';
}

class NotificationModel {
  final String id;

  /// 'follow' or 'post'
  final String type;

  final String recipientId;
  final String senderId;
  final String senderUsername;
  final String senderPhotoUrl;

  /// Only set when type == 'post'
  final String? postId;
  final String? postTitle;

  bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.recipientId,
    required this.senderId,
    required this.senderUsername,
    required this.senderPhotoUrl,
    this.postId,
    this.postTitle,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      type: data['type'] ?? NotificationType.follow,
      recipientId: data['recipientId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderUsername: data['senderUsername'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'] ?? '',
      postId: data['postId'],
      postTitle: data['postTitle'],
      isRead: data['isRead'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'recipientId': recipientId,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'senderPhotoUrl': senderPhotoUrl,
      if (postId != null) 'postId': postId,
      if (postTitle != null) 'postTitle': postTitle,
      'isRead': isRead,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
