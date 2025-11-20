import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  // instance Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Accessing current User
  User? get _currentUser => _auth.currentUser;

  // Stream untuk cek status connected/login (Auth Gate)
  Stream<User?> get authstateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateDisplayName({required String username}) async {
    await _currentUser!.updateDisplayName(username);
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await _currentUser!.reauthenticateWithCredential(credential);
    await _currentUser!.delete();
    await _auth.signOut();
  }

  Future<void> resetPasswordFromCurrent({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await _currentUser!.reauthenticateWithCredential(credential);
    await _currentUser!.updatePassword(newPassword);
  }
}
