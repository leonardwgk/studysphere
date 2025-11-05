import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // instance Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream untuk cek status login (Auth Gate)
  Stream<User?> get authstateChanges => _auth.authStateChanges();

  // Login dengan Email & Password
  // Future<User?> signInWithEmailAndPassword(String email, String password) async {
  //   try {
  //     UserCredential result = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return result.user;
  //   } catch (e) {
  //     print("FAIL TO SIGN IN");
  //     print(e.toString());
  //     return null;
  //   }
  // }
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Register dengan Email & Password
  // Future<User?> registerWithEmailAndPassword(String email, String password) async {
  //   try {
  //     UserCredential result = await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return result.user;
  //   } catch (e) {
  //     print("FAIL TO REGISTER");
  //     print(e.toString());
  //     return null;
  //   }
  // }
  Future<void> registerWithEmailAndPassword(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print("FAIL TO SIGN OUT");
      print(e.toString());
      return;
    }
  }
}