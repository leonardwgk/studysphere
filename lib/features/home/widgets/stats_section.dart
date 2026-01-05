import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/calender/providers/calendar_provider.dart';
import 'package:studysphere_app/features/home/widgets/study_stat_card.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int finalSeconds = seconds % 60;

    String h = hours.toString().padLeft(2, '0');
    String m = minutes.toString().padLeft(2, '0');
    String s = finalSeconds.toString().padLeft(2, '0');

    return "$h:$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    // Use CalendarProvider for stats (with caching)
    return Consumer<CalendarProvider>(
      builder: (context, calendarProvider, child) {
        return Row(
          children: <Widget>[
            Expanded(
              child: StudyStatCard(
                title: "Today's Study Time",
                duration: _formatTime(calendarProvider.todayAll),
                focusTime: _formatTime(calendarProvider.todayFocus),
                breakTime: _formatTime(calendarProvider.todayBreak),
                color: Colors.orange,
                icon: Icons.access_time_filled,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: StudyStatCard(
                title: "Weekly Study Time",
                duration: _formatTime(calendarProvider.weeklyAll),
                focusTime: _formatTime(calendarProvider.weeklyFocus),
                breakTime: _formatTime(calendarProvider.weeklyBreak),
                color: Colors.deepPurple,
                icon: Icons.calendar_today,
              ),
            ),
          ],
        );
      },
    );
  }
}
