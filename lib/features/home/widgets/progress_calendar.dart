import 'package:flutter/material.dart';
import 'package:studysphere_app/shared/models/summary_model.dart';
import 'package:studysphere_app/features/home/widgets/day_circle.dart';

class ProgressCalendar extends StatelessWidget {
  final VoidCallback onViewCalendar;
  final List<SummaryModel> weeklySummaries;

  const ProgressCalendar({
    super.key,
    required this.onViewCalendar,
    required this.weeklySummaries,
  });

  @override
  Widget build(BuildContext context) {
    // Hitung tanggal Senin-Minggu minggu ini
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    // Buat map untuk lookup cepat: date string -> summary
    final Map<String, SummaryModel> summaryMap = {};
    for (var summary in weeklySummaries) {
      summaryMap[summary.date] = summary;
    }

    // Generate 7 hari (Senin-Minggu)
    final List<_DayData> weekDays = [];
    final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final dateStr = _formatDate(date);
      final summary = summaryMap[dateStr];
      final bool hasStudied = summary != null && summary.dailyTotal > 0;
      final bool isToday = _isSameDay(date, now);
      final bool isFuture = date.isAfter(now);

      weekDays.add(
        _DayData(
          dayName: dayNames[i],
          dayNumber: date.day.toString(),
          hasStudied: hasStudied,
          isToday: isToday,
          isFuture: isFuture,
          totalMinutes: summary?.dailyTotal ?? 0,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Judul dan View Calendar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Your progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: onViewCalendar,
                child: const Row(
                  children: [
                    Text(
                      'View Calendar',
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: Colors.blue, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Baris Hari (M, T, W, T, F, S, S)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              return DayCircle(
                day: day.dayName,
                number: day.dayNumber,
                isHighlighted: day.hasStudied,
                isToday: day.isToday,
                isFuture: day.isFuture,
                color: _getColorForDuration(day.totalMinutes),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Warna berdasarkan durasi belajar (seperti GitHub contributions)
  Color _getColorForDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    if (minutes == 0) return Colors.grey;
    if (minutes < 30) return Colors.orange[300]!;
    if (minutes < 60) return Colors.orange[400]!;
    if (minutes < 120) return Colors.orange[600]!;
    return Colors.orange[800]!; // 2+ jam
  }
}

class _DayData {
  final String dayName;
  final String dayNumber;
  final bool hasStudied;
  final bool isToday;
  final bool isFuture;
  final int totalMinutes;

  _DayData({
    required this.dayName,
    required this.dayNumber,
    required this.hasStudied,
    required this.isToday,
    required this.isFuture,
    required this.totalMinutes,
  });
}
