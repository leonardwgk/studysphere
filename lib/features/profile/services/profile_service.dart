import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart'; // Pastikan sudah: flutter pub add intl
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

  // 3. Update Profile
  Future<void> updateProfile({
    required String uid,
    required String username,
    required String? dob,
    String? photoUrl,
  }) async {
    try {
      Map<String, dynamic> data = {'username': username, 'dateOfBirth': dob};
      if (photoUrl != null) data['photoUrl'] = photoUrl;
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Gagal update profile: $e');
    }
  }

  // 4. Update Stats (Increment)
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

  // 5. AMBIL DATA DARI 'daily_summaries' (KODE BARU)
  Future<Map<String, dynamic>> getWeeklyProgress(String uid) async {
    DateTime now = DateTime.now();
    // Cari hari Senin minggu ini
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    // Format tanggal ke String "YYYY-MM-DD" agar cocok dengan StudyService
    // Kita butuh range dari Senin sampai Minggu
    String startString = DateFormat('yyyy-MM-dd').format(startOfWeek);
    
    try {
      // Query ke collection 'daily_summaries'
      // Filter: userId user ini DAN tanggal >= hari Senin
      QuerySnapshot snapshot = await _firestore
          .collection('daily_summaries')
          .where('userId', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: startString) 
          .get();

      // Siapkan wadah data 7 hari (0.0 detik)
      List<double> dailyTotals = List.filled(7, 0.0);
      double totalWeekSeconds = 0;

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Ambil string tanggal "2025-01-10"
        String dateStr = data['date'];
        // Parse balik ke DateTime untuk tahu ini hari apa
        DateTime dateObj = DateFormat('yyyy-MM-dd').parse(dateStr);
        
        // Ambil 'dailyFocus' (sesuai field di StudyService kamu)
        // Gunakan (num?) agar aman convert int/double
        double duration = (data['dailyFocus'] as num?)?.toDouble() ?? 0.0;

        // Tentukan index (Senin=0 ... Minggu=6)
        int dayIndex = dateObj.weekday - 1;
        
        if (dayIndex >= 0 && dayIndex < 7) {
          dailyTotals[dayIndex] = duration; // Timpa/Isi data hari itu
          totalWeekSeconds += duration;
        }
      }

      // Hitung rata-rata (dibagi hari yang sudah lewat)
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
      // Jika error (misal index belum dibuat), return kosong
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