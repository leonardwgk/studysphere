import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _username;
  bool _isLoading = false;

  String? get username => _username;
  bool get isLoading => _isLoading;

  Future<void> fetchUser(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        _username = doc.data()?['username'] as String?;
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearUser() {
    _username = null;
    notifyListeners();
  }
}
