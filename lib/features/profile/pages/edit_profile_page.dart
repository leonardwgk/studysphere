import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:studysphere_app/features/auth/data/models/user_model.dart';
import 'package:studysphere_app/features/profile/services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileService _profileService = ProfileService();
  
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;

  File? _selectedImage; 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 1. Isi form dengan data user yang sekarang (Pre-fill)
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    // Asumsi di Model belum ada dob, kita kosongkan dulu. 
    // Nanti kalau UserModel sudah diupdate ada field dob, ganti jadi: text: widget.user.dob
    _dobController = TextEditingController(); 
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Logic pilih foto dari galeri
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Logic simpan perubahan
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      String? newPhotoUrl;

      // A. Jika ada foto baru, upload dulu
      if (_selectedImage != null) {
        newPhotoUrl = await _profileService.uploadImage(
          widget.user.uid, 
          _selectedImage!
        );
      }

      // B. Update data teks ke Firestore
      await _profileService.updateProfile(
        uid: widget.user.uid,
        username: _usernameController.text,
        dob: _dobController.text,
        photoUrl: newPhotoUrl, 
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context); // Kembali ke halaman Profile
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            icon: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveProfile,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- Foto Profil ---
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!) as ImageProvider
                        : NetworkImage(
                            widget.user.photoUrl.isNotEmpty
                                ? widget.user.photoUrl
                                : 'https://ui-avatars.com/api/?name=${widget.user.username}',
                          ),
                  ),
                  const Positioned(
                    bottom: 0, right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- Form Input ---
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _emailController,
              readOnly: true, // Email gaboleh diedit sembarangan
              style: const TextStyle(color: Colors.grey),
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _dobController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Date of Birth', 
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _dobController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}