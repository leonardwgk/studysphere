import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studysphere_app/features/auth/data/models/user_model.dart';

class AuthService {
  // Instance Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Accessing current User
  User? get _currentUser => _auth.currentUser;

  // Stream untuk cek status connected/login (Auth Gate)
  Stream<User?> get authstateChanges => _auth.authStateChanges();

  // --- LOGIN ---
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // SELF-HEALING: Jika login Auth sukses tapi data Firestore hilang
    if (userCredential.user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          print("DEBUG: Ghost user detected! Creating missing Firestore data...");
          await _createUserFirestoreData(userCredential.user!);
          print("DEBUG: Self-healing complete.");
        }
      } catch (e) {
        print("ERROR: Self-healing check failed: $e");
      }
    }

    return userCredential;
  }

  // --- REGISTER ---
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
      // 2. Buat data di Firestore (Usernames + Users) via Transaksi
      await _createUserFirestoreData(userCredential.user!);
    } catch (e) {
      print("DEBUG: Transaction failed with error: $e");

      // Cleanup: Jika Firestore gagal, hapus akun Auth agar tidak 'nyangkut'
      try {
        await userCredential.user?.delete();
        print("DEBUG: Auth user deleted successfully.");
      } catch (deleteError) {
        print("ERROR: Failed to delete user from Auth: $deleteError");
      }
      rethrow; // Lempar error ke UI agar bisa ditampilkan snackbar
    }

    // 3. Sign out agar user harus login ulang
    await _auth.signOut();

    return userCredential;
  }

  // --- FETCH DATA (Jembatan ke Provider) ---
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("ERROR: Gagal mengambil data user: $e");
      return null;
    }
  }

  // --- HELPER: Create User Data & Transaction (Logic Inti) ---
  Future<void> _createUserFirestoreData(User user) async {
    String uid = user.uid;
    String email = user.email ?? "";
    String baseUsername = email.split('@')[0].toLowerCase();

    bool uniqueUsernameCreated = false;
    String finalUsername = "";

    // Loop untuk memastikan username unik
    while (!uniqueUsernameCreated) {
      try {
        await _firestore.runTransaction((transaction) async {
          // Generate username kandidat (contoh: "henry" atau "henry4821")
          String candidateUsername = finalUsername.isEmpty
              ? baseUsername
              : "$baseUsername${_generateRandomDigits(4)}";

          // Cek di koleksi 'usernames' (Satpam)
          DocumentReference usernameRef = _firestore
              .collection('usernames')
              .doc(candidateUsername);

          DocumentSnapshot usernameSnapshot = await transaction.get(usernameRef);

          if (usernameSnapshot.exists) {
            finalUsername = "taken"; // Trigger untuk generate angka random
            throw Exception("Username taken");
          }

          // --- JIKA SUKSES (Username Unik) ---

          // 1. Kunci username di registry
          transaction.set(usernameRef, {
            'uid': uid,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // 2. Simpan profile lengkap di 'users' (Sesuai Data Design)
          transaction.set(_firestore.collection('users').doc(uid), {
            'uid': uid,
            'email': email,
            'username': candidateUsername,
            'photoUrl': '',
            'searchKeywords': [candidateUsername.toLowerCase()], 
            'totalFocusTime': 0,
            'totalBreakTime': 0,
            'followingCount': 0,
            'followersCount': 0,
            'badges': [],
            'createdAt': FieldValue.serverTimestamp(),
          });

          finalUsername = candidateUsername;
        }, timeout: const Duration(seconds: 10));

        uniqueUsernameCreated = true;
        print("DEBUG: Username created: $finalUsername");

      } catch (e) {
        if (e.toString().contains("Username taken")) {
          print("DEBUG: Username taken, retrying with suffix...");
          finalUsername = "retry"; // Memicu generate angka random di loop berikutnya
          continue;
        }
        rethrow;
      }
    }
  }

  // Helper: Generate Angka Random
  String _generateRandomDigits(int length) {
    var rng = Random();
    return List.generate(length, (_) => rng.nextInt(10)).join();
  }

  // --- ACCOUNT MANAGEMENT ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({required String username}) async {
    await _currentUser!.updateDisplayName(username);
  }

  Future<void> deleteAccount({required String email, required String password}) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    await _currentUser!.reauthenticateWithCredential(credential);
    await _currentUser!.delete();
    await _auth.signOut();
  }

  Future<void> resetPasswordFromCurrent({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPassword);
    await _currentUser!.reauthenticateWithCredential(credential);
    await _currentUser!.updatePassword(newPassword);
  }
}