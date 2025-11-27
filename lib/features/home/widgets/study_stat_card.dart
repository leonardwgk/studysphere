import 'package:flutter/material.dart';

class StudyStatCard extends StatelessWidget {
  final String title;
  final String duration;
  final String focusTime;
  final String breakTime;
  final Color color;
  final IconData icon;

  const StudyStatCard({
    required this.title,
    required this.duration,
    required this.focusTime,
    required this.breakTime,
    required this.color,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Icon dan Judul
          Row(
            children: <Widget>[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Durasi
          const Text(
            'Duration',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            duration,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 10),

          // Fokus Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Focus Time',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                focusTime,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // Break Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Break Time',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                breakTime,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
