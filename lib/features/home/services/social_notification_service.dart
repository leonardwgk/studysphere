import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:studysphere_app/shared/models/notification_model.dart';

/// Handles reading/writing social notifications (follow, post) in Firestore.
///
/// Firestore schema:
///   notifications/{notificationId}
///     - type: 'follow' | 'post'
///     - recipientId, senderId, senderUsername, senderPhotoUrl
///     - postId?, postTitle?
///     - isRead, createdAt
class SocialNotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUid => _auth.currentUser?.uid ?? '';

  // ---------------------------------------------------------------------------
  // WRITE
  // ---------------------------------------------------------------------------

  /// Write a single "follow" notification when the current user follows another.
  Future<void> writeFollowNotification({
    required String senderId,
    required String senderUsername,
    required String senderPhotoUrl,
    required String recipientId,
  }) async {
    if (senderId == recipientId) return; // Don't notify yourself

    try {
      await _db.collection('notifications').add({
        'type': NotificationType.follow,
        'recipientId': recipientId,
        'senderId': senderId,
        'senderUsername': senderUsername,
        'senderPhotoUrl': senderPhotoUrl,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('📬 Follow notification written → $recipientId');
    } catch (e) {
      debugPrint('Error writing follow notification: $e');
    }
  }

  /// Write "post" notifications to all followers of the current user.
  /// Fire-and-forget: non-blocking.
  Future<void> writePostNotificationsToFollowers({
    required String senderId,
    required String senderUsername,
    required String senderPhotoUrl,
    required String postId,
    required String postTitle,
  }) async {
    try {
      // Fetch all follower UIDs
      final followersSnapshot = await _db
          .collection('follows')
          .doc(senderId)
          .collection('followers')
          .get();

      if (followersSnapshot.docs.isEmpty) return;

      // Write a notification for each follower using a batch (max 500 per batch)
      const batchLimit = 499;
      int count = 0;
      WriteBatch batch = _db.batch();

      for (final doc in followersSnapshot.docs) {
        final followerUid = doc['uid'] as String? ?? doc.id;
        if (followerUid == senderId) continue; // skip sender

        final notifRef = _db.collection('notifications').doc();
        batch.set(notifRef, {
          'type': NotificationType.post,
          'recipientId': followerUid,
          'senderId': senderId,
          'senderUsername': senderUsername,
          'senderPhotoUrl': senderPhotoUrl,
          'postId': postId,
          'postTitle': postTitle,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        count++;
        if (count >= batchLimit) {
          await batch.commit();
          batch = _db.batch();
          count = 0;
        }
      }

      if (count > 0) await batch.commit();
      debugPrint(
        '📬 Post notifications written to ${followersSnapshot.docs.length} followers',
      );
    } catch (e) {
      debugPrint('Error writing post notifications: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // READ
  // ---------------------------------------------------------------------------

  /// Real-time stream of the current user's notifications, newest first.
  /// Sorting is done in Dart to avoid requiring a composite Firestore index.
  Stream<List<NotificationModel>> getNotificationsStream() {
    if (_currentUid.isEmpty) return const Stream.empty();

    return _db
        .collection('notifications')
        .where('recipientId', isEqualTo: _currentUid)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();
          // Sort newest-first in memory (avoids composite index requirement)
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list.take(50).toList();
        });
  }

  /// Real-time stream of unread notification count for the current user.
  Stream<int> getUnreadCountStream() {
    if (_currentUid.isEmpty) return const Stream.empty();

    return _db
        .collection('notifications')
        .where('recipientId', isEqualTo: _currentUid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ---------------------------------------------------------------------------
  // MARK READ
  // ---------------------------------------------------------------------------

  /// Mark a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications for the current user as read.
  Future<void> markAllAsRead() async {
    if (_currentUid.isEmpty) return;
    try {
      final snapshot = await _db
          .collection('notifications')
          .where('recipientId', isEqualTo: _currentUid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }
}
