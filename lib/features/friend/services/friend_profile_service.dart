// lib/features/friend/services/friend_profile_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studysphere_app/shared/models/user_model.dart';

class FriendProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream untuk mendapatkan data user berdasarkan userId
  Stream<UserModel> getFriendUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot);
      } else {
        throw Exception('User not found');
      }
    });
  }

  /// Method alternatif: Ambil data user sekali saja (Future)
  Future<UserModel> getFriendUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();

    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    } else {
      throw Exception('User not found');
    }
  }
}
