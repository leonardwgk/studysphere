import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studysphere_app/shared/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  // 1. Deklarasi Variabel Utama (Konsisten pakai _firestore dan _auth)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser?.uid ?? '';

  // --- FUNGSI SEARCH ---
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      String searchKey = query.toLowerCase();

      final snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: searchKey)
          .where('username', isLessThan: '$searchKey\uf8ff')
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

  // --- CEK STATUS FOLLOW ---
  Future<bool> isFollowing(String targetUid) async {
    if (currentUid.isEmpty || targetUid.isEmpty) return false;

    try {
      final doc = await _firestore
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

  // --- LIST UID YANG DI-FOLLOW (Untuk Logic Tombol) ---
  Future<Set<String>> getFollowingUids() async {
    if (currentUid.isEmpty) return {};

    try {
      final snapshot = await _firestore
          .collection('follows')
          .doc(currentUid)
          .collection('following')
          .get();

      // Mengambil field 'uid' dari dokumen subcollection
      return snapshot.docs.map((doc) => doc['uid'] as String).toSet();
    } catch (e) {
      print("Error fetch following UIDs: $e");
      return {};
    }
  }

  // --- ACTION: FOLLOW USER ---
  Future<void> followUser(String targetUid) async {
    if (currentUid.isEmpty || targetUid.isEmpty) {
      throw Exception('Invalid user IDs');
    }

    try {
      final batch = _firestore.batch();

      // 1. Tambahkan relasi di koleksi 'follows'
      final followingRef = _firestore
          .collection('follows')
          .doc(currentUid)
          .collection('following')
          .doc(targetUid);

      final followerRef = _firestore
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
      final currentUserRef = _firestore.collection('users').doc(currentUid);
      final targetUserRef = _firestore.collection('users').doc(targetUid);

      batch.update(currentUserRef, {'followingCount': FieldValue.increment(1)});
      batch.update(targetUserRef, {'followersCount': FieldValue.increment(1)});

      await batch.commit();
      print("✅ Successfully followed user: $targetUid");
    } catch (e) {
      print("❌ Error following user: $e");
      rethrow;
    }
  }

  // --- ACTION: UNFOLLOW USER ---
  Future<void> unfollowUser(String targetUid) async {
    if (currentUid.isEmpty || targetUid.isEmpty) {
      throw Exception('Invalid user IDs');
    }

    try {
      final batch = _firestore.batch();

      // 1. Hapus relasi di koleksi 'follows'
      final followingRef = _firestore
          .collection('follows')
          .doc(currentUid)
          .collection('following')
          .doc(targetUid);

      final followerRef = _firestore
          .collection('follows')
          .doc(targetUid)
          .collection('followers')
          .doc(currentUid);

      batch.delete(followingRef);
      batch.delete(followerRef);

      // 2. Update counter di dokumen user
      final currentUserRef = _firestore.collection('users').doc(currentUid);
      final targetUserRef = _firestore.collection('users').doc(targetUid);

      batch.update(currentUserRef, {
        'followingCount': FieldValue.increment(-1),
      });

      batch.update(targetUserRef, {'followersCount': FieldValue.increment(-1)});

      await batch.commit();
      print("Successfully unfollowed user: $targetUid");
    } catch (e) {
      print("Error unfollowing user: $e");
      rethrow;
    }
  }

  // --- AMBIL FULL LIST FOLLOWING (Untuk Halaman List) ---
  Future<List<UserModel>> getFollowingList(String targetUserId) async {
    try {
      final snapshot = await _firestore
          .collection('follows')
          .doc(targetUserId)
          .collection('following')
          .get();

      if (snapshot.docs.isEmpty) return [];

      List<String> followingIds =
          snapshot.docs.map((doc) => doc['uid'] as String).toList();

      return await _getUsersByIds(followingIds);
    } catch (e) {
      print("Error fetching following list: $e");
      return [];
    }
  }

  // --- AMBIL FULL LIST FOLLOWERS (Untuk Halaman List) ---
  Future<List<UserModel>> getFollowersList(String targetUserId) async {
    try {
      final snapshot = await _firestore
          .collection('follows')
          .doc(targetUserId)
          .collection('followers')
          .get();

      if (snapshot.docs.isEmpty) return [];

      List<String> followerIds =
          snapshot.docs.map((doc) => doc['uid'] as String).toList();

      return await _getUsersByIds(followerIds);
    } catch (e) {
      print("Error fetching followers list: $e");
      return [];
    }
  }

  // --- HELPER: AMBIL DATA USER DARI LIST ID ---
  Future<List<UserModel>> _getUsersByIds(List<String> ids) async {
    List<UserModel> users = [];
    for (var id in ids) {
      try {
        var doc = await _firestore.collection('users').doc(id).get();
        if (doc.exists) {
          users.add(UserModel.fromFirestore(doc));
        }
      } catch (e) {
        print("Skip user $id error: $e");
      }
    }
    return users;
  }
}