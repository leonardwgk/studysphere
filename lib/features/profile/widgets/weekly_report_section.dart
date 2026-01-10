import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/auth/providers/user_provider.dart';
import 'package:studysphere_app/features/profile/services/profile_service.dart';

class WeeklyReportSection extends StatelessWidget {
  const WeeklyReportSection({super.key});

  // Format detik ke "4h 26m"
  String _formatDuration(double totalSeconds) {
    int seconds = totalSeconds.toInt();
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    if (h == 0 && m == 0) return '0m';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    // Ambil User ID dari Provider
    final user = context.watch<UserProvider>().user;

    // Jika user belum load, sembunyikan section
    if (user == null) return const SizedBox();

    final profileService = ProfileService();

    return FutureBuilder<Map<String, dynamic>>(
      future: profileService.getWeeklyProgress(user.uid),
      builder: (context, snapshot) {
        // Data Default
        List<double> dailyData = List.filled(7, 0.0);
        double totalTime = 0;
        double avgTime = 0;
        String dateRange = "Loading...";

        if (snapshot.hasData) {
          final data = snapshot.data!;
          dailyData = data['dailyTotals'] as List<double>;
          totalTime = data['totalWeekSeconds'] as double;
          avgTime = data['averageSeconds'] as double;

          final start = data['startOfWeek'] as DateTime;
          final end = data['endOfWeek'] as DateTime;
          dateRange =
              "(${DateFormat('d MMM').format(start)} - ${DateFormat('d MMM').format(end)})";
        }

        // Cari nilai tertinggi agar grafik proporsional
        double maxVal = dailyData.reduce(
          (curr, next) => curr > next ? curr : next,
        );
        if (maxVal == 0) maxVal = 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: .05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Rata-rata ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDuration(avgTime),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Daily average study time',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        dateRange,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Grafik Batang ---
                  SizedBox(
                    height: 180,
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _ChartBar(
                                label: 'Mon',
                                value: dailyData[0],
                                max: maxVal,
                              ),
                              _ChartBar(
                                label: 'Tue',
                                value: dailyData[1],
                                max: maxVal,
                              ),
                              _ChartBar(
                                label: 'Wed',
                                value: dailyData[2],
                                max: maxVal,
                              ),
                              _ChartBar(
                                label: 'Thu',
                                value: dailyData[3],
                                max: maxVal,
                              ),
                              _ChartBar(
                                label: 'Fri',
                                value: dailyData[4],
                                max: maxVal,
                              ),
                              _ChartBar(
                                label: 'Sat',
                                value: dailyData[5],
                                max: maxVal,
                              ),
                              _ChartBar(
                                label: 'Sun',
                                value: dailyData[6],
                                max: maxVal,
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  // --- Footer Total ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Study Time',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _formatDuration(totalTime),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChartBar extends StatelessWidget {
  final String label;
  final double value;
  final double max;

  const _ChartBar({
    required this.label,
    required this.value,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    double heightPct = value / max;
    if (heightPct < 0.05 && value > 0)
      heightPct = 0.05; // Minimal height visually

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (value > 0)
          Text(
            "${(value / 3600).toStringAsFixed(1)}h",
            style: const TextStyle(fontSize: 8, color: Colors.grey),
          ),
        const SizedBox(height: 4),

        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          width: 30,
          height: value == 0 ? 5 : (120 * heightPct), // Max height visual 120
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: value > 0
                  ? [Colors.blue.shade200, Colors.blue.shade600]
                  : [Colors.grey.shade200, Colors.grey.shade300],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
