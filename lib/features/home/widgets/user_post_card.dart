import 'package:flutter/material.dart';
import 'package:studysphere_app/shared/models/post_model.dart';
import 'package:studysphere_app/shared/widgets/custom_avatar.dart';
import 'package:intl/intl.dart'; // for DateFormat

class UserPostCard extends StatefulWidget {
  final PostModel post; // Pakai Model langsung (DTO)

  const UserPostCard({required this.post, super.key});

  @override
  State<UserPostCard> createState() => _UserPostCardState();
}

class _UserPostCardState extends State<UserPostCard> {
  bool _isExpanded = false; // State untuk mengontrol teks

  // Helper: Mengubah detik (int) ke format HH:mm:ss
  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d';
    } else if (now.year == dateTime.year) {
      // Format: 01 Dec
      return DateFormat('dd MMM').format(dateTime);
    } else {
      // Format: 10 Nov 24
      return DateFormat('dd MMM yy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hitung total durasi
    final totalDuration = widget.post.focusTime + widget.post.breakTime;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Warna kartu
        borderRadius: BorderRadius.circular(16), // Sudut melengkung
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05), // Bayangan sangat tipis
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Post
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                CustomAvatar(
                  photoUrl: widget.post.userPhotoUrl,
                  name: widget.post.username,
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      // Gunakan Row untuk nama dan tanggal
                      children: [
                        Text(
                          widget.post.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "• ${_formatTimestamp(widget.post.createdAt)}", // HASIL LOGIKA TANGGAL
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Studying: ${widget.post.label}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Konten Gambar
          if (widget.post.imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.post.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Tetap gunakan errorBuilder untuk jaga-jaga jika URL-nya corrupt
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),

          // Jika ada gambar, kasih jarak 10. Jika tidak ada, kasih jarak 5 saja biar rapat.
          SizedBox(height: widget.post.imageUrl.isNotEmpty ? 10 : 5),

          // Caption & Metrics
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // DESCRIPTION dengan fitur Read More
                if (widget.post.description.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.description,
                        maxLines: _isExpanded
                            ? null
                            : 3, // Tampilkan semua jika ekspand
                        overflow: _isExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      // Tampilkan tombol hanya jika teks cukup panjang (> 100 karakter misalnya)
                      if (widget.post.description.length > 200)
                        InkWell(
                          onTap: () =>
                              setState(() => _isExpanded = !_isExpanded),
                          child: Text(
                            _isExpanded ? "Show Less" : "Read More",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Duration',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          _formatDuration(totalDuration),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Focus: ${_formatDuration(widget.post.focusTime)}',
                        ),
                        Text(
                          'Break: ${_formatDuration(widget.post.breakTime)}',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
