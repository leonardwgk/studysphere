import 'package:flutter/material.dart';
import 'package:studysphere_app/features/home/widgets/day_circle.dart';

class ProgressCalendar extends StatefulWidget {
  final VoidCallback onViewCalendar;
  const ProgressCalendar({super.key, required this.onViewCalendar});

  @override
  State<ProgressCalendar> createState() => _ProgressCalendarState();
}

class _ProgressCalendarState extends State<ProgressCalendar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white, // warna latar Container
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
                onTap: widget.onViewCalendar, // Panggil fungsi callback saat diklik
                child: Row(
                  children: const [
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
            children: const <Widget>[
              DayCircle(
                day: 'M',
                number: '3',
                isHighlighted: true,
                color: Colors.orange,
              ),
              DayCircle(day: 'T', number: '4', isHighlighted: false),
              DayCircle(
                day: 'W',
                number: '5',
                isHighlighted: true,
                color: Colors.orange,
              ),
              DayCircle(day: 'T', number: '6', isHighlighted: false),
              DayCircle(
                day: 'F',
                number: '7',
                isHighlighted: false,
                color: Colors.grey,
              ),
              DayCircle(day: 'S', number: '8', isHighlighted: false),
              DayCircle(day: 'S', number: '9', isHighlighted: false),
            ],
          ),
        ],
      ),
    );
  }
}
