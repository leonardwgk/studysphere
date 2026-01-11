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
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
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
      final ref = FirebaseStorage.instance.ref().child('users/$uid/profile.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Gagal upload gambar: $e');
    }
  }

  // 3. Update Profile (Firestore & Firebase Auth)
  Future<void> updateProfile({
    required String uid,
    required String username,
    // Parameter 'dob' SUDAH DIHAPUS
    String? photoUrl,
  }) async {
    try {
      // A. Update Database (Firestore)
      Map<String, dynamic> data = {'username': username};
      if (photoUrl != null) data['photoUrl'] = photoUrl;
      
      await _firestore.collection('users').doc(uid).update(data);

      // B. Update Firebase Authentication (Akun Login)
      User? user = _auth.currentUser;
      if (user != null) {
        // Update Nama di Auth
        if (username != user.displayName) {
          await user.updateDisplayName(username);
        }
        
        // Update Foto di Auth (jika ada perubahan)
        if (photoUrl != null && photoUrl != user.photoURL) {
          await user.updatePhotoURL(photoUrl);
        }

        // Refresh agar perubahan terbaca di aplikasi
        await user.reload(); 
      }

    } catch (e) {
      throw Exception('Gagal update profile: $e');
    }
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