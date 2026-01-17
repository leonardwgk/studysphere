import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studysphere_app/shared/models/user_model.dart';
import 'package:studysphere_app/features/auth/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  // Using UserService from auth feature (proper architecture)
  final UserService _userService = UserService();

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
      _userSubscription = _userService.getUserStream().listen(
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
