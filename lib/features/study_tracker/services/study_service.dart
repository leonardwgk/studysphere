import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:studysphere_app/features/home/services/social_notification_service.dart';
import 'package:studysphere_app/shared/models/user_model.dart';
import 'package:studysphere_app/shared/utils/image_compression.dart';

class StudyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('User not authenticated. Cannot perform study operations.');
    }
    return uid;
  }

  // Fungsi untuk menyimpan sesi ke Firestore (mengikuti Data Access Pattern)
  Future<void> saveAndPostSession({
    required UserModel user,
    required int focusTime,
    required int breakTime,
    required String label,
    required String title,
    String? description,
    String? imageUrl,
  }) async {
    final batch = _db.batch();
    final now = DateTime.now();
    final dateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // 1. Update/Set 'daily_summaries'
    final summaryRef = _db
        .collection('daily_summaries')
        .doc('${_uid}_$dateStr');
    batch.set(summaryRef, {
      'userId': _uid,
      'date': dateStr,
      'dailyFocus': FieldValue.increment(focusTime),
      'dailyBreak': FieldValue.increment(breakTime),
      'dailyTotal': FieldValue.increment(focusTime + breakTime),
      'labelsStudied': FieldValue.arrayUnion([label]),
    }, SetOptions(merge: true));

    // 2. Update total di 'users'
    final userRef = _db.collection('users').doc(_uid);
    batch.update(userRef, {
      'totalFocusTime': FieldValue.increment(focusTime),
      'totalBreakTime': FieldValue.increment(breakTime),
    });

    // 3. Tambah ke koleksi 'posts'
    final postRef = _db.collection('posts').doc();
    batch.set(postRef, {
      'userId': user.uid,
      'username': user.username, // Denormalized
      'userPhotoUrl': user.photoUrl, // Denormalized
      'title': title,
      'description': description ?? '',
      'label': label,
      'imageUrl': imageUrl ?? '', // Link dari Storage
      'focusTime': focusTime,
      'breakTime': breakTime,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    // Fire-and-forget: send post notifications to all followers
    SocialNotificationService().writePostNotificationsToFollowers(
      senderId: user.uid,
      senderUsername: user.username,
      senderPhotoUrl: user.photoUrl,
      postId: postRef.id,
      postTitle: title,
    );
  }

  Future<String?> uploadStudyImage(File file) async {
    File? compressed;
    try {
      // Compress image to stay under 1 MB with adaptive quality
      compressed = await compressImage(file);

      final String fileName = 'post_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('posts/$_uid/$fileName');

      await ref.putFile(compressed);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error upload image: $e');
      return null;
    } finally {
      // Clean up temp file regardless of success or failure
      if (compressed != null && compressed.path != file.path) {
        await deleteTempFile(compressed);
      }
    }
  }

  Future<Map<String, int>> getUserStats({
    required String userId,
    required DateTime startDate,
  }) async {
    try {
      // Query: Ambil semua sesi user ini yang dibuat SETELAH startDate
      QuerySnapshot snapshot = await _db
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .get();

      int totalFocus = 0;
      int totalBreak = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalFocus += (data['focusTime'] as int? ?? 0);
        totalBreak += (data['breakTime'] as int? ?? 0);
      }

      return {'focus': totalFocus, 'break': totalBreak};
    } catch (e) {
      debugPrint("Error calculating stats: $e");
      return {'focus': 0, 'break': 0};
    }
  }
}
