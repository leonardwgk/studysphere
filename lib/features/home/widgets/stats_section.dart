import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/home/providers/home_providers.dart';
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
    // Gunakan HomeProvider untuk statistik dinamis
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        return Row(
          children: <Widget>[
            Expanded(
              child: StudyStatCard(
                title: "Today's Study Time",
                duration: _formatTime(homeProvider.todayAll),
                focusTime: _formatTime(homeProvider.todayFocus),
                breakTime: _formatTime(homeProvider.todayBreak),
                color: Colors.orange,
                icon: Icons.access_time_filled,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: StudyStatCard(
                title: "Weekly Study Time",
                duration: _formatTime(homeProvider.weeklyAll),
                focusTime: _formatTime(homeProvider.weeklyFocus),
                breakTime: _formatTime(homeProvider.weeklyBreak),
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
