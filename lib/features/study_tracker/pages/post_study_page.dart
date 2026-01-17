import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/auth/providers/user_provider.dart';
import '../services/study_service.dart';

class PostStudyPage extends StatefulWidget {
  final int totalFocusTime;
  final int totalBreakTime;
  final String initialLabel;

  const PostStudyPage({
    super.key,
    required this.totalFocusTime,
    required this.totalBreakTime,
    required this.initialLabel,
  });

  @override
  State<PostStudyPage> createState() => _PostStudyPageState();
}

class _PostStudyPageState extends State<PostStudyPage> {
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  late String _selectedLabel;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  // Daftar kategori tetap untuk menjaga kualitas data (ML-Ready)
  final List<String> _categories = [
    "Matematika",
    "Fisika",
    "Biologi",
    "Kimia",
    "Sejarah",
    "Bahasa Inggris",
    "Bahasa Indonesia",
    "Lainnya",
  ];

  @override
  void initState() {
    super.initState();
    _selectedLabel = widget.initialLabel;
    _titleController.text = "Sesi Belajar ${widget.initialLabel}";
  }

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
        final userProvider = Provider.of<UserProvider>(
          context,
          listen: false,
        ); // UserProvider can't be changed in this context
        final studyService = StudyService();
        String? uploadedImageUrl;

        // 1. Upload & Kompres Gambar ke Storage (jika ada)
        if (_selectedImage != null) {
          uploadedImageUrl = await studyService.uploadStudyImage(
            _selectedImage!,
          );
          if (uploadedImageUrl == null) {
            throw Exception("Gagal mengunggah gambar. Periksa koneksi Anda.");
          }
        }

        // 2. Simpan Sesi & Post ke Firestore (Atomic Batch)
        await studyService.saveAndPostSession(
          user: userProvider.user!,
          focusTime: widget.totalFocusTime,
          breakTime: widget.totalBreakTime,
          label: _selectedLabel, // Data Kategorikal (ML)
          title: _titleController.text.trim(), // Data Kreatif (UI)
          description: _descriptionController.text.trim(),
          imageUrl: uploadedImageUrl,
        );

        if (!mounted) return;

        // 3. REFRESH PROVIDER
        // Kita panggil initUserStream untuk memastikan data terbaru ter-load.
        // Tidak perlu 'await' karena fungsi ini void.
        userProvider.initUserStream();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session successfully shared!'),
            backgroundColor: Colors.green,
          ),
        );

        // Kembali ke Home
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Share Session',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: _handlePost,
                    child: const Text(
                      'POST',
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
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- STATS CARD ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: .1),
                    ),
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

                // --- IMAGE PICKER ---
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        style: BorderStyle.solid,
                      ),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Add a photo to your post",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                // --- CATEGORY DROPDOWN ---
                const Text(
                  "Subject Category",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLabel,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  items: _categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedLabel = val!),
                ),
                const SizedBox(height: 20),

                // --- TITLE INPUT ---
                const Text(
                  "Session Title",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _titleController,
                  maxLength: 50, // Batasi judul maksimal 50 karakter
                  decoration: InputDecoration(
                    counterText:
                        "", // Sembunyikan angka counter jika ingin tampilan clean
                    hintText: 'e.g. Mastering Calculus Basics',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.title_outlined),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 20),

                // --- DESCRIPTION INPUT ---
                const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  maxLength: 600, // Batasi deskripsi maksimal 600 karakter
                  maxLines: null, // Biarkan mengembang ke bawah
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Write about your study session...',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      ],
    );
  }
}
