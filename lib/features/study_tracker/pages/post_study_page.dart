import 'package:flutter/material.dart';
import '../services/study_service.dart'; // Import service baru Anda

class PostStudyPage extends StatefulWidget {
  final int totalFocusTime;
  final int totalBreakTime;

  const PostStudyPage({
    super.key,
    required this.totalFocusTime,
    required this.totalBreakTime,
  });

  @override
  State<PostStudyPage> createState() => _PostStudyPageState();
}

class _PostStudyPageState extends State<PostStudyPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false; // Loading state untuk UI

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  void _handlePost() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Panggil StudyService untuk simpan ke 3 koleksi sekaligus (Transaction/Batch)
        // Menggunakan judul sebagai 'label' mata pelajaran sesuai Data Design Anda
        await StudyService().saveCompleteSession(
          focusTime: widget.totalFocusTime,
          breakTime: widget.totalBreakTime,
          label: _titleController.text.trim(),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session saved and posted!')),
        );

        // Kembali ke Home setelah sukses
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving session: $e')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Share Session'),
          automaticallyImplyLeading: false,
          actions: [
            _isLoading 
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : TextButton(
                  onPressed: _handlePost,
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Section (Tetap sama)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Focus Time',
                        _formatTime(widget.totalFocusTime),
                        Icons.timer,
                        Colors.blue,
                      ),
                      _buildStatItem(
                        'Break Time',
                        _formatTime(widget.totalBreakTime),
                        Icons.coffee,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Title Input (Wajib)
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Subject/Label',
                    hintText: 'e.g. Mathematics, Science',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Label is required' : null,
                ),
                const SizedBox(height: 16),

                // Description Input (Opsional)
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}