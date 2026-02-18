import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/auth/providers/user_provider.dart';
import 'package:studysphere_app/features/profile/services/profile_service.dart';

class WeeklyReportSection extends StatelessWidget {
  const WeeklyReportSection({super.key});

  // Format seconds to readable string
  String _formatDuration(double totalSeconds) {
    int seconds = totalSeconds.toInt();
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    if (h == 0 && m == 0) return '0m';
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  // Format seconds to short bar label
  String _formatBarLabel(double totalSeconds) {
    if (totalSeconds == 0) return '';
    int seconds = totalSeconds.toInt();
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) return const SizedBox();

    final profileService = ProfileService();

    return FutureBuilder<Map<String, dynamic>>(
      future: profileService.getWeeklyProgress(user.uid),
      builder: (context, snapshot) {
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
              "${DateFormat('d MMM').format(start)} - ${DateFormat('d MMM').format(end)}";
        }

        double maxVal = dailyData.reduce(
          (curr, next) => curr > next ? curr : next,
        );
        if (maxVal == 0) maxVal = 1;

        // Determine today's day index (0=Mon, 6=Sun)
        final now = DateTime.now();
        final todayIndex = now.weekday - 1; // weekday: 1=Mon, 7=Sun

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
                  // --- Header with stats ---
                  Row(
                    children: [
                      // Daily average
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDuration(avgTime),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Daily Average',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // Total + date range
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatDuration(totalTime),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateRange,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Bar Chart ---
                  SizedBox(
                    height: 180,
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(7, (i) {
                              const days = [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun'
                              ];
                              return Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  child: _ChartBar(
                                    label: days[i],
                                    value: dailyData[i],
                                    max: maxVal,
                                    formattedValue:
                                        _formatBarLabel(dailyData[i]),
                                    isToday: i == todayIndex,
                                  ),
                                ),
                              );
                            }),
                          ),
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
  final String formattedValue;
  final bool isToday;

  const _ChartBar({
    required this.label,
    required this.value,
    required this.max,
    required this.formattedValue,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    double heightPct = value / max;
    if (heightPct < 0.06 && value > 0) {
      heightPct = 0.06;
    }

    final bool hasValue = value > 0;
    final Color barColor = isToday ? Colors.blue : Colors.blue.shade300;
    final Color emptyColor =
        isToday ? Colors.blue.shade50 : Colors.grey.shade100;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Value label above bar
        if (hasValue)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              formattedValue,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isToday ? Colors.blue[700] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (!hasValue) const SizedBox(height: 16),

        // Bar
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: hasValue ? (130 * heightPct).clamp(8, 130) : 6,
          decoration: BoxDecoration(
            color: hasValue ? barColor : emptyColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),

        // Day label
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
            color: isToday ? Colors.blue[700] : Colors.grey[600],
          ),
        ),

        // Today dot indicator
        if (isToday)
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        if (!isToday) const SizedBox(height: 7),
      ],
    );
  }
}
