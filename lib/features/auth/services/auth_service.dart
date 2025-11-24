import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  // instance Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Accessing current User
  User? get _currentUser => _auth.currentUser;

  // Stream untuk cek status connected/login (Auth Gate)
  Stream<User?> get authstateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // SELF-HEALING: Check if Firestore data exists
    if (userCredential.user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          print(
            "DEBUG: Ghost user detected! Creating missing Firestore data...",
          );
          await _createUserFirestoreData(userCredential.user!);
          print("DEBUG: Self-healing complete.");
        }
      } catch (e) {
        print("ERROR: Self-healing check failed: $e");
        // Don't block login if this check fails, but user might have issues
      }
    }

    return userCredential;
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // 1. Buat user di Firebase Auth
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    try {
      // 2. Buat data di Firestore (Usernames + Users)
      await _createUserFirestoreData(userCredential.user!);
    } catch (e) {
      print("DEBUG: Transaction failed with error: $e");

      // Cleanup: If Firestore fails (network, etc.), delete the Auth user
      // so we don't have a dangling user without Firestore data.
      try {
        print(
          "DEBUG: Attempting to delete Auth user due to Firestore failure...",
        );
        await userCredential.user?.delete();
        print("DEBUG: Auth user deleted successfully.");
      } catch (deleteError) {
        print("ERROR: Failed to delete user from Auth: $deleteError");
      }
      // Jika error lain (koneksi, permission), lempar keluar
      rethrow;
    }

    // 4. Sign out agar tidak langsung login
    await _auth.signOut();

    return userCredential;
  }

  // Helper: Create User Data (Extracted for Self-Healing)
  Future<void> _createUserFirestoreData(User user) async {
    String uid = user.uid;
    String email = user.email ?? "";
    String baseUsername = email.split('@')[0].toLowerCase();

    bool uniqueUsernameCreated = false;
    String finalUsername = "";

    // 3. Loop cek keunikan
    while (!uniqueUsernameCreated) {
      try {
        print("DEBUG: Starting Firestore transaction for username check...");
        await _firestore.runTransaction((transaction) async {
          // Percobaan pertama: Coba pakai username asli (misal: "johndoe")
          // Percobaan kedua/loop: Pakai username + angka random (misal: "johndoe4921")
          String candidateUsername = finalUsername.isEmpty
              ? baseUsername
              : "$baseUsername${_generateRandomDigits(4)}";

          DocumentReference usernameRef = _firestore
              .collection('usernames')
              .doc(candidateUsername);

          DocumentSnapshot usernameSnapshot = await transaction.get(
            usernameRef,
          );

          if (usernameSnapshot.exists) {
            // Jika sudah ada, lempar error local untuk memicu catch dan loop ulang
            // Kita set finalUsername jadi string kosong dulu biar loop berikutnya generate angka
            finalUsername = "taken";
            throw Exception("Username taken");
          }

          // --- JIKA SUKSES (Username Unik) ---

          // 1. Simpan di registry usernames
          transaction.set(usernameRef, {
            'uid': uid,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // 2. Simpan profile user
          transaction.set(_firestore.collection('users').doc(uid), {
            'uid': uid,
            'email': email,
            'username': candidateUsername, // Simpan username yg final
            'photoUrl': '',
            'currentStreak': 0,
            'lastStudyDate': '',
            'totalFocusTime': 0,
            'totalBreakTime': 0,
            'followers': [],
            'following': [],
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Set flag keluar loop
          finalUsername = candidateUsername;
        }, timeout: const Duration(seconds: 10)); // Add timeout

        uniqueUsernameCreated = true;
        print("DEBUG: Username created: $finalUsername");
      } catch (e) {
        if (e.toString().contains("Username taken")) {
          print("DEBUG: Username taken, retrying with suffix...");
          // Pastikan loop lanjut dan akan generate angka di putaran berikutnya
          finalUsername = "retry";
          continue;
        }
        // Rethrow other errors to be handled by caller
        rethrow;
      }
    }
  }

  // Helper: Generate Angka Random
  String _generateRandomDigits(int length) {
    var rng = Random();
    // Menghasilkan angka seperti "4821"
    return List.generate(length, (_) => rng.nextInt(10)).join();
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({required String username}) async {
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
