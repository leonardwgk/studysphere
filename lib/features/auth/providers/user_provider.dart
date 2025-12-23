import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/data/models/user_model.dart';
import 'package:studysphere_app/features/auth/services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user; //  Menyimpan data sesuai dengan model users
  bool _isLoading = false;

  UserModel? get user=> _user;
  bool get isLoading => _isLoading;

  final AuthService _authService = AuthService(); // Penanganan data ke services

  Future<void> fetchUser(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userData = await _authService.getUserData(uid);
      if(userData != null) _user = userData;
    } catch (e) {
      debugPrint("Error fetching user: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
