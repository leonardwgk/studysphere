import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/data/models/user_model.dart';
import 'package:studysphere_app/features/friend/services/friend_service.dart';

class FriendProvider extends ChangeNotifier {
  final FriendService _friendService = FriendService();

  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce; // Timer untuk menunda pencarian

  // Getters
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  // Fungsi Search dengan Debounce
  void onSearchChanged(String query) {
    // 1. Batalkan timer sebelumnya jika user masih mengetik
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 2. Jika text kosong, bersihkan hasil
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    // 3. Set loading indicator lokal (biar UI responsif)
    _isLoading = true;
    notifyListeners();

    // 4. Mulai timer baru (tunggu 500ms)
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await _friendService.searchUsers(query);
      _searchResults = results;
    } catch (e) {
      print("Provider Error: $e");
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Membersihkan hasil saat keluar halaman
  void clearSearch() {
    _searchResults = [];
    _isLoading = false;
    notifyListeners(); // Optional, tergantung kebutuhan UI
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}