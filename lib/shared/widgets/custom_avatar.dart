import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double radius;

  const CustomAvatar({
    super.key,
    required this.photoUrl,
    required this.name,
    this.radius = 20, // Default radius
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
      child: !hasPhoto
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.deepPurple.shade600,
                fontWeight: FontWeight.bold,
                fontSize:
                    radius * 0.8, // Ukuran teks proporsional dengan radius
              ),
            )
          : null,
    );
  }
}
