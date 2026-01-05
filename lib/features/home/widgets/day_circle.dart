import 'package:flutter/material.dart';

class DayCircle extends StatelessWidget {
  final String day;
  final String number;
  final bool isHighlighted;
  final bool isToday;
  final bool isFuture;
  final Color color;

  const DayCircle({
    required this.day,
    required this.number,
    required this.isHighlighted,
    this.isToday = false,
    this.isFuture = false,
    this.color = Colors.orange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Determine circle appearance
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isHighlighted) {
      // Hari dengan aktivitas belajar
      bgColor = color;
      borderColor = color;
      textColor = Colors.white;
    } else if (isToday) {
      // Hari ini tapi belum belajar
      bgColor = Colors.transparent;
      borderColor = Colors.black;
      textColor = Colors.black;
    } else if (isFuture) {
      // Hari mendatang
      bgColor = Colors.grey[200]!;
      borderColor = Colors.grey[300]!;
      textColor = Colors.grey[400]!;
    } else {
      // Hari lampau tanpa aktivitas
      bgColor = Colors.transparent;
      borderColor = Colors.grey[400]!;
      textColor = Colors.black;
    }

    return Column(
      children: <Widget>[
        Text(
          day, 
          style: TextStyle(
            fontSize: 12, 
            color: isToday ? Colors.black : Colors.grey,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            border: Border.all(
              color: borderColor,
              width: isToday ? 2 : 1,
            ),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
