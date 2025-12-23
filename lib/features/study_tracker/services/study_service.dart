import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Fungsi untuk menyimpan sesi ke Firestore (mengikuti Data Access Pattern)
  Future<void> saveCompleteSession({
    required int focusTime,
    required int breakTime,
    required String label,
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

    await batch.commit();
  }
}