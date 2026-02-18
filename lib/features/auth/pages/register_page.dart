import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/data/field_errors.dart';
import 'package:studysphere_app/features/auth/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:studysphere_app/shared/constant.dart';
import 'package:studysphere_app/shared/password_validator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();

  // text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // loading state
  bool _isLoading = false;

  // password visibility toggles
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // show password strength after user starts typing
  bool _passwordHasInput = false;

  String? _emailErrorText;
  String? _passwordErrorText;
  String? _confirmPasswordErrorText;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {
      _passwordHasInput = _passwordController.text.isNotEmpty;
      if (_passwordErrorText != null) _passwordErrorText = null;
      if (_confirmPasswordErrorText != null &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text) {
        _confirmPasswordErrorText = null;
      }
    });
  }

  void _onConfirmPasswordChanged() {
    setState(() {
      if (_confirmPasswordErrorText != null) _confirmPasswordErrorText = null;
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_onConfirmPasswordChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // fungsi register
  void _register() async {
    // Set loading + clear errors
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
    } else if (PasswordValidator.getStrength(password) <= 0.5) {
      _passwordErrorText = "Password minimal harus kekuatan 'Sedang'.";
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Registrasi Berhasil! Silakan login dengan akun Anda.",
            ),
            backgroundColor: Colors.green,
          ),
        );
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

  /// Builds a subtle inline strength indicator below the password field.
  Widget _buildStrengthIndicator() {
    if (!_passwordHasInput) return const SizedBox.shrink();

    final strength = PasswordValidator.getStrength(_passwordController.text);
    final label = PasswordValidator.getStrengthLabel(_passwordController.text);
    final allMet = PasswordValidator.isValid(_passwordController.text);

    // Dynamic hint: show what's still missing, or a success message
    final unmet = PasswordValidator.validate(_passwordController.text)
        .where((r) => !r.isMet)
        .map((r) => r.label.toLowerCase())
        .toList();

    final hint = allMet ? 'Password kuat!' : 'Perlu: ${unmet.join(', ')}';

    Color barColor;
    if (strength <= 0.25) {
      barColor = Colors.red;
    } else if (strength <= 0.5) {
      barColor = Colors.orange;
    } else if (strength <= 0.75) {
      barColor = Colors.amber.shade700;
    } else {
      barColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6.0, left: 2.0, right: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thin strength bar — 4 segmented blocks
          Row(
            children: List.generate(4, (i) {
              final segmentFilled = strength > (i / 4);
              return Expanded(
                child: Container(
                  height: 3.5,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: segmentFilled
                        ? barColor
                        : Colors.grey.shade200,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          // Single-line hint
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 11,
                    color: allMet ? Colors.green.shade600 : Colors.grey[500],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
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
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16.0),

                  // --- TextField Password ---
                  TextField(
                    controller: _passwordController,
                    decoration: kGetTextFieldDecoration(
                      hintText: "Password",
                      icon: Icons.lock_outlined,
                      errorText: _passwordErrorText,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                  ),
                  // Inline strength indicator
                  _buildStrengthIndicator(),
                  const SizedBox(height: 16.0),

                  // --- TextField Konfirmasi Password ---
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: kGetTextFieldDecoration(
                      hintText: "Konfirmasi Password",
                      icon: Icons.lock_outlined,
                      errorText: _confirmPasswordErrorText,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _register(),
                  ),
                  const SizedBox(height: 30.0),

                  // --- Register Button or Loading ---
                  Builder(
                    builder: (context) {
                      final passwordStrength = PasswordValidator.getStrength(
                        _passwordController.text,
                      );
                      final canRegister = passwordStrength > 0.5;

                      if (_isLoading) {
                        return const CircularProgressIndicator();
                      }

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: canRegister ? _register : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            backgroundColor: canRegister
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                          ),
                          child: Text(
                            "Daftar",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: canRegister
                                  ? Colors.white
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      );
                    },
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
