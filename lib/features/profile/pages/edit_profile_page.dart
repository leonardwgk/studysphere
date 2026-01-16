import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studysphere_app/shared/models/user_model.dart';
import 'package:studysphere_app/features/profile/services/profile_service.dart';
import 'package:flutter/services.dart';

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

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      String? newPhotoUrl;

      // Upload foto jika ada
      if (_selectedImage != null) {
        newPhotoUrl = await _profileService.uploadImage(
          widget.user.uid,
          _selectedImage!,
        );
      }

      // Update Firestore (Akan otomatis cek unik di dalam service)
      await _profileService.updateProfile(
        uid: widget.user.uid,
        username: _usernameController.text.trim(), // Pakai trim() biar bersih
        photoUrl: newPhotoUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green, // Kasih warna hijau kalau sukses
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // Bersihkan pesan error (hapus kata "Exception: ")
        String errorMessage = e.toString().replaceAll("Exception: ", "");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red, // Kasih warna merah kalau gagal
          ),
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
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
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
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _usernameController,
              inputFormatters: [
                FilteringTextInputFormatter.deny(
                  RegExp(r'\s'),
                ), // Hanya izinkan huruf
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-z0-9_.]'),
                ), // Izinkan underscore, titik, huruf kecik dan angka
              ],
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                hintText: 'Only lowercase letters',
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _emailController,
              readOnly: true,
              style: const TextStyle(color: Colors.grey),
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
