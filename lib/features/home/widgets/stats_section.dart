import 'package:flutter/material.dart';
import 'package:studysphere_app/features/home/widgets/study_stat_card.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        // Today's Study Time (Orange)
        Expanded(
          child: StudyStatCard(
            title: "Today's Study Time",
            duration: '1:20:21',
            focusTime: '55:12',
            breakTime: '25:09',
            color: Colors.orange,
            icon: Icons.access_time_filled,
          ),
        ),
        SizedBox(width: 15),
        // Weekly Study Time (Purple)
        Expanded(
          child: StudyStatCard(
            title: "Weekly Study Time",
            duration: '35:19:01',
            focusTime: '30:18:01',
            breakTime: '5:01:00',
            color: Colors.deepPurple,
            icon: Icons.calendar_today,
          ),
        ),
      ],
    );
  }
}
