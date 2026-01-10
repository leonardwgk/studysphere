import 'dart:async'; // 1. Wajib untuk StreamSubscription
import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/data/models/user_model.dart';
import 'package:studysphere_app/features/profile/services/profile_service.dart'; // 2. Ganti AuthService ke ProfileService

class UserProvider extends ChangeNotifier {
  // Kita pakai ProfileService karena di situ ada fungsi stream-nya
  final ProfileService _profileService = ProfileService();
  
  UserModel? _user; 
  StreamSubscription<UserModel>? _userSubscription;

  // Getter
  UserModel? get user => _user;
  
  // (Opsional) Helper untuk cek apakah sedang loading data awal
  bool get isLoading => _user == null; 

  // --- LOGIKA BARU: STREAM ---
  // Fungsi ini dipanggil sekali saat aplikasi mulai / user login
  void initUserStream() {
    // 1. Batalkan koneksi lama jika ada (biar memori aman)
    _userSubscription?.cancel();

    // 2. Mulai dengarkan data dari Firebase secara LIVE
    try {
      _userSubscription = _profileService.getUserStream().listen(
        (updatedUser) {
          _user = updatedUser;
          notifyListeners(); // Memberi tahu UI: "Data berubah, refresh dong!"
        },
        onError: (error) {
          debugPrint("Error Stream User: $error");
        },
      );
    } catch (e) {
      debugPrint("Gagal inisialisasi stream: $e");
    }
  }

  // --- LOGIKA LAMA (Tetap dipakai saat Logout) ---
  void clearUser() {
    _userSubscription?.cancel(); // Matikan stream saat logout
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}