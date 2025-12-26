import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/data/field_errors.dart';
import 'package:studysphere_app/features/auth/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:studysphere_app/shared/constant.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();

  // text controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // loading state
  bool _isLoading = false;

  String? _emailErrorText;
  String? _passwordErrorText;
  String? _confirmPasswordErrorText;

  // fungsi register
  void _register() async {
    // Set loading + clear
    setState(() {
      _isLoading = true;
      _emailErrorText = null;
      _passwordErrorText = null;
      _confirmPasswordErrorText = null;
    });
    // validasi input
    final String email = _emailController.text.trim();
    final bool isEmailValid = EmailValidator.validate(email);

    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    bool hasClientError = false;

    if (email.isEmpty) {
      _emailErrorText = "Email tidak boleh kosong.";
      hasClientError = true;
    } else if (!isEmailValid) {
      _emailErrorText = "Format email tidak valid.";
      hasClientError = true;
    }

    if (password.isEmpty) {
      _passwordErrorText = "Password tidak boleh kosong.";
      hasClientError = true;
    } else if (password.length < 6) {
      _passwordErrorText = "Password minimal 6 karakter.";
      hasClientError = true;
    }

    if (confirmPassword.isEmpty) {
      _confirmPasswordErrorText = "Konfirmasi password tidak boleh kosong.";
      hasClientError = true;
    } else if (password.isNotEmpty && password != confirmPassword) {
      _confirmPasswordErrorText = "Password dan konfirmasi tidak sesuai.";
      hasClientError = true;
    }

    if (hasClientError) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Panggil auth service
    try {
      await _authService.registerWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        // BERI TAHU USER KALAU SUKSES
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Registrasi Berhasil! Silakan login dengan akun Anda.",
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Kembali ke halaman login
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final errors = mapFirebaseAuthError(e);
      setState(() {
        _emailErrorText = errors.email;
        _passwordErrorText = errors.password;
      });

      if (errors.global != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errors.global!)));
      }
    } catch (e) {
      if (!mounted) return;
      // Handle generic errors (e.g. Firestore network error)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          // Biar bisa scroll pas keyboard muncul
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- LOGO ---
                  Image.asset('assets/img/logo.png', height: 120),
                  const SizedBox(height: 40.0),

                  // --- TextField Email ---
                  TextField(
                    controller: _emailController,
                    onChanged: (_) {
                      if (_emailErrorText != null) {
                        setState(() {
                          _emailErrorText = null;
                        });
                      }
                    },
                    decoration: kGetTextFieldDecoration(
                      hintText: "Email",
                      icon: Icons.lock_outlined,
                      errorText:
                          _emailErrorText, // Ganti dengan variabel error password
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16.0),

                  // --- TextField Password ---
                  TextField(
                    controller: _passwordController,
                    onChanged: (_) {
                      if (_passwordErrorText != null) {
                        setState(() {
                          _passwordErrorText = null;
                        });
                      }
                    },
                    decoration: kGetTextFieldDecoration(
                      hintText: "Password (Minimal 6 karakter)",
                      icon: Icons.lock_outlined,
                      errorText:
                          _passwordErrorText, // Ganti dengan variabel error password
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),

                  // --- TextField Konfirmasi Password ---
                  TextField(
                    controller: _confirmPasswordController,
                    onChanged: (_) {
                      if (_confirmPasswordErrorText != null) {
                        setState(() {
                          _confirmPasswordErrorText = null;
                        });
                      }
                    },
                    decoration: kGetTextFieldDecoration(
                      hintText: "Konfirmasi Password",
                      icon: Icons.lock_outlined,
                      errorText:
                          _confirmPasswordErrorText, // Ganti dengan variabel error password
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30.0),

                  // Tampilkan Tombol atau Loading
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                            child: const Text(
                              "Daftar",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 4.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sudah punya akun? "),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Login di sini",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
