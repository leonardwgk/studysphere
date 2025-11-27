import 'package:flutter/material.dart';

class DayCircle extends StatelessWidget {
  final String day;
  final String number;
  final bool isHighlighted;
  final Color color;

  const DayCircle({
    required this.day,
    required this.number,
    required this.isHighlighted,
    this.color = Colors.black, // Default color
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFuture =
        number == '7'; // Contoh asumsi F=7 adalah hari yang akan datang

    return Column(
      children: <Widget>[
        Text(day, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 5),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isHighlighted
                ? color
                : (isFuture ? Colors.grey[300] : Colors.transparent),
            border: Border.all(
              color: isFuture ? Colors.grey : Colors.grey[400]!,
              width: 1,
            ),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: isHighlighted ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
