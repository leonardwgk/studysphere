import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:studysphere_app/shared/models/post_model.dart';

/// HomeService handles social feed-related data operations.
/// Following feature-first architecture, feed logic lives in home feature.
class HomeService {
  final FirebaseFirestore _db;

  /// Constructor with optional Firestore injection for testability
  HomeService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  /// Fetch social feed posts from all users (Global Feed)
  Future<List<PostModel>> getFeedPosts() async {
    try {
      // Query posts ordered by creation time (newest first)
      // Simple pagination with limit
      QuerySnapshot querySnapshot = await _db
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      // Transform DocumentSnapshots to PostModel list
      return querySnapshot.docs.map((doc) {
        return PostModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      debugPrint("Error at getFeedPosts: $e");
      rethrow;
    }
  }
}
