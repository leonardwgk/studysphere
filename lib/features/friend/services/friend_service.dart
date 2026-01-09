import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studysphere_app/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Fungsi pencarian username
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      // Query Logic: Mencari username yang DIMULAI dengan teks query
      // Catatan: Firestore case-sensitive.
      // Idealnya data di DB disimpan juga dalam format lowercase (misal field: searchKeywords)
      String searchKey = query.toLowerCase();

      final snapshot = await _db
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: searchKey)
          .where('username', isLessThan: searchKey + '\uf8ff')
          .limit(20) // Batasi hasil agar tidak terlalu banyak
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where(
            (user) => user.uid != _currentUid,
          ) // Hanya ambil user yang BUKAN diri sendiri
          .toList();
    } catch (e) {
      print("Error searching users: $e");
      return [];
    }
  }
}
