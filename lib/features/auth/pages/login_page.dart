import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/data/field_errors.dart';
import 'package:studysphere_app/features/auth/services/auth_service.dart';
import 'package:studysphere_app/features/auth/pages/register_page.dart';
import 'package:studysphere_app/shared/constant.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  String? _emailErrorText;
  String? _passwordErrorText;

  void _login() async {
    // 1. Validasi awal
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _emailErrorText = _emailController.text.trim().isEmpty ? "Email wajib diisi" : null;
        _passwordErrorText = _passwordController.text.isEmpty ? "Password wajib diisi" : null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _emailErrorText = null;
      _passwordErrorText = null;
    });

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // AuthGate akan mendeteksi perubahan dan memindahkan halaman secara otomatis
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final errors = mapFirebaseAuthError(e);

      setState(() {
        _emailErrorText = errors.email;
        _passwordErrorText = errors.password;
      });

      if (errors.global != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errors.global!)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                      icon: Icons.email_outlined,
                      errorText: _emailErrorText,
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
                      hintText: "Password",
                      icon: Icons.lock_outlined,
                      errorText:
                          _passwordErrorText, // Ganti dengan variabel error password
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30.0),

                  // --- Tombol Login ---
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 4.0),

                  // -- Tombol ke halaman Register ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Belum punya akun? "),
                      TextButton(
                        onPressed: () {
                          // Pindah ke halaman register
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Daftar di sini",
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
