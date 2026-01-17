import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studysphere_app/shared/models/user_model.dart';

/// UserService handles user data stream operations.
/// Following feature-first architecture, user stream lives in auth feature.
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get real-time stream of current user's data
  Stream<UserModel> getUserStream() {
    String uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot);
      }
      throw Exception("User not found");
    });
  }
}
