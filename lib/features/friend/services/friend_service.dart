import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studysphere_app/features/auth/data/models/user_model.dart';

class FriendService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fungsi pencarian username
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      // Query Logic: Mencari username yang DIMULAI dengan teks query
      // Catatan: Firestore case-sensitive.
      // Idealnya data di DB disimpan juga dalam format lowercase (misal field: searchKeywords)
      
      final snapshot = await _db
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: query + '\uf8ff')
          .limit(20) // Batasi hasil agar tidak terlalu banyak
          .get();

      return snapshot.docs.map((doc) {
        // Mapping dari DocumentSnapshot ke UserModel
        // Pastikan UserModel Anda punya factory .fromMap atau sesuaikan di sini
        return UserModel.fromMap(doc.data()); 
      }).toList();
    } catch (e) {
      print("Error searching users: $e");
      return [];
    }
  }
}