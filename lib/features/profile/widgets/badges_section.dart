import 'package:flutter/material.dart';

class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Badges
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(text: 'Badges '),
                  TextSpan(
                    text: '12',
                    style: TextStyle(color: Colors.blue),
                  ),
                  TextSpan(
                    text: '/62',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Row(
                children: [
                  Text('View all', style: TextStyle(color: Colors.blue)),
                  Icon(Icons.chevron_right, color: Colors.blue, size: 20),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Badge Cards Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildBadgeCard('Achievem.\nName', Icons.explore),
              _buildBadgeCard('Achievem.\nName', Icons.star),
              _buildBadgeCard('Achievem.\nName', Icons.hourglass_top),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(String title, IconData icon) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          // Badge Icon Placeholder (Circle with gradient/color)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.orange.shade300, Colors.yellow.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
