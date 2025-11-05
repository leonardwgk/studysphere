import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/services/auth_service.dart';
import 'package:studysphere_app/features/auth/pages/register_page.dart';

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

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try{
      // Panggil service
      await _authService.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      // AuthGate otomatis pindah halaman jika berhasil login
    }on FirebaseAuthException catch (e){
      if(!mounted) return;
      setState(() {
        _isLoading = false;
      });
      // Tampilkan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login Gagal"))
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
                  // Image(image: AssetImage('assets/images/FullLogo.jpg')),
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
                      hintText: "Password",
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

                  // --- Tombol Login ---
                  _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                  const SizedBox(height: 20.0),

                  // -- Tombol ke halaman Register ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Belum punya akun? "),
                      TextButton(
                        onPressed: (){
                          // Pindah ke halaman register
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text("Daftar di sini"),
                      )
                    ],
                  )
                ],
              ),
            )
          )
        )
      ),
    );
  }
}