import 'package:firebase_auth/firebase_auth.dart';

class FieldErrors {
  final String? email;
  final String? password;
  final String? global;
  const FieldErrors({this.email, this.password, this.global});
}

FieldErrors mapFirebaseAuthError(FirebaseAuthException e) {
  final code = e.code.toLowerCase();
  String? emailErr;
  String? passErr;
  String? globalMsg;

  switch (code) {
    // Shared/login
    case 'invalid-email':
      emailErr = 'Email tidak valid.';
      break;
    case 'user-not-found':
      emailErr = 'Akun tidak ditemukan.';
      break;
    case 'wrong-password':
      passErr = 'Password salah.';
      break;
    case 'user-disabled':
      emailErr = 'Akun ini dinonaktifkan.';
      break;
    case 'invalid-credential':
    case 'channel-error':
      emailErr = 'Email atau password tidak sesuai.';
      passErr = 'Email atau password tidak sesuai.';
      break;

    // Register-specific
    case 'email-already-in-use':
      emailErr = 'Email sudah terdaftar.';
      break;
    case 'weak-password':
      passErr = 'Password terlalu lemah (minimal 6 karakter).';
      break;
    case 'operation-not-allowed':
      globalMsg = 'Metode pendaftaran tidak diaktifkan.';
      break;

    // Generic
    case 'too-many-requests':
      globalMsg = 'Terlalu banyak percobaan. Coba lagi nanti.';
      break;
    case 'network-request-failed':
      globalMsg = 'Periksa koneksi internet Anda.';
      break;
    default:
      globalMsg = e.message ?? 'Terjadi kesalahan.';
  }

  return FieldErrors(email: emailErr, password: passErr, global: globalMsg);
}
