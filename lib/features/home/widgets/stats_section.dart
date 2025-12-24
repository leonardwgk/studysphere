import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/auth/providers/user_provider.dart';
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
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Null safety
        final user = userProvider.user;
        if (user == null) return const Center(child: CircularProgressIndicator());

        final int totalFocusTime = user.totalFocusTime;
        final int totalBreakTime = user.totalBreakTime;
        final int totalAll = totalFocusTime + totalBreakTime;

        return Row(
          children: <Widget>[
            // Today's Study Time (Orange)
            Expanded(
              child: StudyStatCard(
                title: "Today's Study Time",
                duration: _formatTime(totalAll),
                focusTime: _formatTime(totalFocusTime),
                breakTime: _formatTime(totalBreakTime),
                color: Colors.orange,
                icon: Icons.access_time_filled,
              ),
            ),
            SizedBox(width: 15),
            // Weekly Study Time (Purple)
            Expanded(
              child: StudyStatCard(
                title: "Weekly Study Time",
                duration: _formatTime(totalAll),
                focusTime: _formatTime(totalFocusTime),
                breakTime: _formatTime(totalBreakTime),
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

