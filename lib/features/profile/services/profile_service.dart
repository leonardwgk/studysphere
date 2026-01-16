import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:studysphere_app/features/auth/data/models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Get User Stream
  Stream<UserModel> getUserStream() {
    String uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot);
      } else {
        throw Exception("User not found");
      }
    });
  }

  // 2. Upload Image
  Future<String> uploadImage(String uid, File imageFile) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(
        'users/$uid/profile.jpg',
      );
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Gagal upload gambar: $e');
    }
  }

  // 3. Update Profile dengan Validasi Unik dan Atomic Username Registry
  Future<void> updateProfile({
    required String uid,
    required String username,
    String? photoUrl,
  }) async {
    try {
      // Get current username from users document
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final currentUsername = userDoc.data()?['username'] as String? ?? '';
      final usernameChanged = currentUsername != username;

      if (usernameChanged) {
        // Use transaction for atomic username registry update
        await _firestore.runTransaction((transaction) async {
          // 1. Check if new username already exists in registry
          final newUsernameDoc = await transaction.get(
            _firestore.collection('usernames').doc(username),
          );

          if (newUsernameDoc.exists) {
            // Username taken by someone else
            throw Exception("Username '$username' is already taken.");
          }

          // 2. Delete old username from registry (if exists)
          if (currentUsername.isNotEmpty) {
            transaction.delete(
              _firestore.collection('usernames').doc(currentUsername),
            );
          }

          // 3. Create new username in registry
          transaction.set(_firestore.collection('usernames').doc(username), {
            'uid': uid,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // 4. Update users document
          Map<String, dynamic> userData = {
            'username': username,
            'searchKeywords': _generateSearchKeywords(username),
          };
          if (photoUrl != null) userData['photoUrl'] = photoUrl;

          transaction.update(_firestore.collection('users').doc(uid), userData);
        });
      } else {
        // Username didn't change, just update other fields
        if (photoUrl != null) {
          await _firestore.collection('users').doc(uid).update({
            'photoUrl': photoUrl,
          });
        }
      }

      // Update Firebase Auth profile
      User? user = _auth.currentUser;
      if (user != null) {
        if (usernameChanged && username != user.displayName) {
          await user.updateDisplayName(username);
        }
        if (photoUrl != null && photoUrl != user.photoURL) {
          await user.updatePhotoURL(photoUrl);
        }
        await user.reload();
      }
    } catch (e) {
      // Rethrow untuk ditangkap oleh UI (EditProfilePage)
      rethrow;
    }
  }

  /// Generate search keywords for username (for user search feature)
  List<String> _generateSearchKeywords(String username) {
    final List<String> keywords = [];
    final lowerUsername = username.toLowerCase();

    // Add progressively longer prefixes
    for (int i = 1; i <= lowerUsername.length; i++) {
      keywords.add(lowerUsername.substring(0, i));
    }

    return keywords;
  }

  // 4. Update Stats
  Future<void> updateStudyStats({
    required String uid,
    required int additionalFocusTime,
    required int additionalBreakTime,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'totalFocusTime': FieldValue.increment(additionalFocusTime),
        'totalBreakTime': FieldValue.increment(additionalBreakTime),
      });
    } catch (e) {
      throw Exception('Gagal update statistik: $e');
    }
  }

  // 5. Get Weekly Progress
  Future<Map<String, dynamic>> getWeeklyProgress(String uid) async {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    String startString = DateFormat('yyyy-MM-dd').format(startOfWeek);

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('daily_summaries')
          .where('userId', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: startString)
          .get();

      List<double> dailyTotals = List.filled(7, 0.0);
      double totalWeekSeconds = 0;

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String dateStr = data['date'];
        DateTime dateObj = DateFormat('yyyy-MM-dd').parse(dateStr);
        double duration = (data['dailyFocus'] as num?)?.toDouble() ?? 0.0;

        int dayIndex = dateObj.weekday - 1;
        if (dayIndex >= 0 && dayIndex < 7) {
          dailyTotals[dayIndex] = duration;
          totalWeekSeconds += duration;
        }
      }

      int daysPassed = now.weekday;
      double averageSeconds = totalWeekSeconds / daysPassed;

      return {
        'dailyTotals': dailyTotals,
        'totalWeekSeconds': totalWeekSeconds,
        'averageSeconds': averageSeconds,
        'startOfWeek': startOfWeek,
        'endOfWeek': startOfWeek.add(const Duration(days: 6)),
      };
    } catch (e) {
      print("Error getting daily_summaries: $e");
      return {
        'dailyTotals': List.filled(7, 0.0),
        'totalWeekSeconds': 0.0,
        'averageSeconds': 0.0,
        'startOfWeek': startOfWeek,
        'endOfWeek': startOfWeek.add(const Duration(days: 6)),
      };
    }
  }
}
