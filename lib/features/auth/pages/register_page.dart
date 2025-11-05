import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  // loading state
  bool _isLoading = false;

  // fungsi register
  void _register() async {

    // validasi input
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    final bool isEmailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
    ).hasMatch(email);

    if(!isEmailValid){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Format email tidak valid."))
      );
      return;
    }

    if(password.length < 6){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password minimal 6 karakter."))
      );
      return;
    }

    // Validasi
    if(password != confirmPassword){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password dan konfirmasi password tidak sesuai"))
      );
      return;
    }

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan password tidak boleh kosong"))
      );
      return;
    }

    // Set loading
    setState(() {
      _isLoading = true;
    });

    // Panggil auth service
    try{
      await _authService.registerWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      if(mounted){
        // Kembali ke halaman login
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e){
      if(!mounted) return;
      setState(() {
        _isLoading = false;
      });

      String errorMessage = "Terjadi kesalahan.";
      if(e.code == 'weak-password'){
        errorMessage = "Password terlalu lemah (minimal 6 karakter).";
      } else if (e.code == 'email-already-in-use'){
        errorMessage = "Email sudah terdaftar.";
      } else if (e.code == 'invalid-email'){
        errorMessage = "Email tidak valid.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage))
      );
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
                  Image.asset(
                    'assets/img/logo.png',
                    height: 120,
                  ),
                  const SizedBox(height: 40.0),

                  // --- TextField Email ---
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16.0),

                  // --- TextField Password ---
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: "Password (minimal 6 karakter)",
                      prefixIcon: Icon(Icons.lock_outlined, color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),

                  // --- TextField Konfirmasi Password ---
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      hintText: "Konfirmasi Password",
                      prefixIcon: Icon(Icons.lock_outlined, color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                        ),
                      ),
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
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: const Text(
                            "Daftar",
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                  const SizedBox(height: 20.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sudah punya akun? "),
                      TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Login di sini",
                        ),
                      )
                    ],
                  )
                ],
              )
            )
          ),
        )
      ),
    );
  }
}