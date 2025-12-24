import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:studysphere_app/features/auth/data/models/user_model.dart';

class StudyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fungsi untuk menyimpan sesi ke Firestore (mengikuti Data Access Pattern)
  Future<void> saveAndPostSession({
    required UserModel user,
    required int focusTime,
    required int breakTime,
    required String label,
    required String title,
    String? description,
    String? imageUrl
  }) async {
    if (_uid.isEmpty) return;

    final batch = _db.batch();
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // 1. Tambah ke koleksi 'sessions'
    final sessionRef = _db.collection('sessions').doc();
    batch.set(sessionRef, {
      'userId': _uid,
      'focusDuration': focusTime,
      'breakDuration': breakTime,
      'totalDuration': focusTime + breakTime,
      'label': label,
      'description': description ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Update/Set 'daily_summaries'
    final summaryRef = _db.collection('daily_summaries').doc('${_uid}_$dateStr');
    batch.set(summaryRef, {
      'userId': _uid,
      'date': dateStr,
      'dailyFocus': FieldValue.increment(focusTime),
      'dailyBreak': FieldValue.increment(breakTime),
      'dailyTotal': FieldValue.increment(focusTime + breakTime),
      'labelsStudied': FieldValue.arrayUnion([label]),
    }, SetOptions(merge: true));

    // 3. Update total di 'users'
    final userRef = _db.collection('users').doc(_uid);
    batch.update(userRef, {
      'totalFocusTime': FieldValue.increment(focusTime),
      'totalBreakTime': FieldValue.increment(breakTime),
    });

    // 4. Tambah ke koleksi 'posts'
    final postRef = _db.collection('posts').doc();
    batch.set(postRef, {
      'userId': user.uid,
      'username': user.username, // Denormalized
      'userPhotoUrl': user.photoUrl, // Denormalized
      'title': title,
      'description': description ?? '',
      'label': label,
      'imageUrl': imageUrl ?? '', // Link dari Storage
      'focusTime': focusTime,
      'breakTime': breakTime,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<String?> uploadStudyImage(File file) async {
  try {
    // 1. Tanya OS: "Mana folder sampah/sementara saya?"
    final Directory tempDir = await getTemporaryDirectory();

    // 2. Buat nama file unik agar tidak bentrok
    final String targetPath = "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    // Kompresi ke format webp atau jpg (webp biasanya lebih kecil)
    XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // Keseimbangan terbaik kualitas/ukuran
      format: CompressFormat.jpeg,
    );

    if (compressedFile == null) return null;

    // 2. Tentukan Jalur Storage (Sesuai Security Rules kita)
    String fileName = "post_${DateTime.now().millisecondsSinceEpoch}.jpg";
    Reference ref = _storage.ref().child("posts/$_uid/$fileName");

    // 3. Upload
    await ref.putFile(File(compressedFile.path));

    final downloadUrl = await ref.getDownloadURL();

    // Cleanup: Hapus file sementara setelah berhasil diunggah
    try {
      final tempFile = File(compressedFile.path);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      print("Gagal menghapus file temp: $e");
    }
    
    return downloadUrl;
  } catch (e) {
    print("Error upload image: $e");
    return null;
  }
}
}