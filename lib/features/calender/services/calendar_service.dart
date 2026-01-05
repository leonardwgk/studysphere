import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studysphere_app/features/home/data/models/summary_model.dart';

class CalendarService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Ambil summary untuk hari ini
  Future<SummaryModel?> getTodaySummary(String userId) async {
    try {
      final now = DateTime.now();
      final dateStr = _formatDate(now);
      final docId = '${userId}_$dateStr';

      final doc = await _db.collection('daily_summaries').doc(docId).get();

      if (doc.exists && doc.data() != null) {
        return SummaryModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint("Error getTodaySummary: $e");
      return null;
    }
  }

  /// Ambil semua summary untuk minggu ini (Senin - Minggu)
  Future<List<SummaryModel>> getWeeklySummaries(String userId) async {
    try {
      final now = DateTime.now();
      // Hitung tanggal Senin minggu ini
      final monday = now.subtract(Duration(days: now.weekday - 1));
      // Hitung tanggal Minggu minggu ini
      final sunday = monday.add(const Duration(days: 6));

      final startDateStr = _formatDate(monday);
      final endDateStr = _formatDate(sunday);

      // Query daily_summaries untuk user ini dalam rentang tanggal
      final querySnapshot = await _db
          .collection('daily_summaries')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startDateStr)
          .where('date', isLessThanOrEqualTo: endDateStr)
          .get();

      return querySnapshot.docs.map((doc) {
        return SummaryModel.fromMap(doc.data());
      }).toList();
    } catch (e) {
      debugPrint("Error getWeeklySummaries: $e");
      return [];
    }
  }

  /// Ambil summary untuk seluruh bulan (untuk calendar markers)
  Future<Map<DateTime, SummaryModel>> getMonthlySummaries(
    String userId,
    int year,
    int month,
  ) async {
    try {
      // Format: YYYY-MM untuk prefix matching
      final monthPrefix = '$year-${month.toString().padLeft(2, '0')}';

      final querySnapshot = await _db
          .collection('daily_summaries')
          .where('userId', isEqualTo: userId)
          .orderBy('date')
          .startAt(['$monthPrefix-01'])
          .endAt(['$monthPrefix-31'])
          .get();

      final Map<DateTime, SummaryModel> result = {};

      for (var doc in querySnapshot.docs) {
        final summary = SummaryModel.fromMap(doc.data());
        // Parse date string ke DateTime
        final parts = summary.date.split('-');
        if (parts.length == 3) {
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          result[DateTime.utc(date.year, date.month, date.day)] = summary;
        }
      }

      return result;
    } catch (e) {
      debugPrint("Error getMonthlySummaries: $e");
      return {};
    }
  }

  /// Ambil semua summary untuk user (untuk historical data di calendar)
  Future<Map<DateTime, SummaryModel>> getAllSummaries(String userId) async {
    try {
      final querySnapshot = await _db
          .collection('daily_summaries')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      final Map<DateTime, SummaryModel> result = {};

      for (var doc in querySnapshot.docs) {
        final summary = SummaryModel.fromMap(doc.data());
        final parts = summary.date.split('-');
        if (parts.length == 3) {
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          result[DateTime.utc(date.year, date.month, date.day)] = summary;
        }
      }

      return result;
    } catch (e) {
      debugPrint("Error getAllSummaries: $e");
      return {};
    }
  }

  /// Ambil detail sessions untuk tanggal tertentu
  Future<List<Map<String, dynamic>>> getSessionsForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      // Buat range untuk hari itu (00:00:00 - 23:59:59)
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _db
          .collection('sessions')
          .where('userId', isEqualTo: userId)
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint("Error getSessionsForDate: $e");
      return [];
    }
  }

  /// Helper: Format DateTime ke string YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Hitung total stats untuk minggu ini dari summaries
  Map<String, int> calculateWeeklyTotals(List<SummaryModel> summaries) {
    int totalFocus = 0;
    int totalBreak = 0;

    for (var summary in summaries) {
      totalFocus += summary.dailyFocus;
      totalBreak += summary.dailyBreak;
    }

    return {
      'focus': totalFocus,
      'break': totalBreak,
      'total': totalFocus + totalBreak,
    };
  }
}
