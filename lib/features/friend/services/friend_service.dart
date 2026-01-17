import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studysphere_app/shared/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  // Fungsi pencarian username
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      String searchKey = query.toLowerCase();

      final snapshot = await _db
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: searchKey)
          .where('username', isLessThan: searchKey + '\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) => user.uid != currentUid)
          .toList();
    } catch (e) {
      print("Error searching users: $e");
      return [];
    }
  }

  // Cek apakah current user mengikuti target user
  Future<bool> isFollowing(String targetUid) async {
    if (currentUid.isEmpty || targetUid.isEmpty) return false;

    try {
      final doc = await _db
          .collection('follows')
          .doc(currentUid)
          .collection('following')
          .doc(targetUid)
          .get();

      return doc.exists;
    } catch (e) {
      print("Error checking follow status: $e");
      return false;
    }
  }

  // AMBIL daftar UID yang sedang di-follow
  Future<Set<String>> getFollowingUids() async {
    if (currentUid.isEmpty) return {};

    try {
      final snapshot = await _db
          .collection('follows')
          .doc(currentUid)
          .collection('following')
          .get();

      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      print("Error fetching following list: $e");
      return {};
    }
  }

  // Follow user
  Future<void> followUser(String targetUid) async {
    if (currentUid.isEmpty || targetUid.isEmpty) {
      throw Exception('Invalid user IDs');
    }

    try {
      final batch = _db.batch();

      // 1. Tambahkan relasi di koleksi 'follows'
      final followingRef = _db
          .collection('follows')
          .doc(currentUid)
          .collection('following')
          .doc(targetUid);

      final followerRef = _db
          .collection('follows')
          .doc(targetUid)
          .collection('followers')
          .doc(currentUid);

      batch.set(followingRef, {
        'uid': targetUid,
        'followedAt': FieldValue.serverTimestamp(),
      });

      batch.set(followerRef, {
        'uid': currentUid,
        'followedAt': FieldValue.serverTimestamp(),
      });

      // 2. Update counter di dokumen user
      final currentUserRef = _db.collection('users').doc(currentUid);
      final targetUserRef = _db.collection('users').doc(targetUid);

      batch.update(currentUserRef, {'followingCount': FieldValue.increment(1)});

      batch.update(targetUserRef, {'followersCount': FieldValue.increment(1)});

      await batch.commit();
      print("✅ Successfully followed user: $targetUid");
    } catch (e) {
      print("❌ Error following user: $e");
      throw e;
    }
  }

  // Unfollow user
  Future<void> unfollowUser(String targetUid) async {
    if (currentUid.isEmpty || targetUid.isEmpty) {
      throw Exception('Invalid user IDs');
    }

    try {
      final batch = _db.batch();

      // 1. Hapus relasi di koleksi 'follows'
      final followingRef = _db
          .collection('follows')
          .doc(currentUid)
          .collection('following')
          .doc(targetUid);

      final followerRef = _db
          .collection('follows')
          .doc(targetUid)
          .collection('followers')
          .doc(currentUid);

      batch.delete(followingRef);
      batch.delete(followerRef);

      // 2. Update counter di dokumen user
      final currentUserRef = _db.collection('users').doc(currentUid);
      final targetUserRef = _db.collection('users').doc(targetUid);

      batch.update(currentUserRef, {
        'followingCount': FieldValue.increment(-1),
      });

      batch.update(targetUserRef, {'followersCount': FieldValue.increment(-1)});

      await batch.commit();
      print("Successfully unfollowed user: $targetUid");
    } catch (e) {
      print("Error unfollowing user: $e");
      throw e;
    }
  }
}
