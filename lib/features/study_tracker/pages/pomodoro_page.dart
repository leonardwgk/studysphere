import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/timer_viewmodel.dart';

// Halaman utama yang membungkus Provider
class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject ViewModel ke dalam Widget Tree
    return ChangeNotifierProvider(
      create: (_) => TimerViewModel(),
      child: const _PomodoroView(),
    );
  }
}

// Widget Tampilan (Private)
class _PomodoroView extends StatelessWidget {
  const _PomodoroView();

  @override
  Widget build(BuildContext context) {
    // Mengambil instance ViewModel
    final viewModel = context.watch<TimerViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- 1. BACKGROUND IMAGE (Garis-garis Abstrak) ---
          // Pastikan Anda punya gambar aset ini, atau gunakan CustomPaint
          Positioned.fill(
            child: Opacity(
              opacity: 0.1, // Dibuat samar agar teks terbaca
              child: Image.asset(
                'assets/images/wavy_bg.png', // Ganti dengan aset Anda
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Container(color: Colors.white), // Fallback
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // --- 2. HEADER (Top Bar) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                  ),
                ),

                const SizedBox(height: 20),

                // --- 3. SUBJECT TITLE ---
                const Text(
                  "#Individually Studying",
                  style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      viewModel.subject,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.edit, size: 18, color: Colors.black54),
                  ],
                ),

                const Spacer(), // Dorong timer ke tengah

                // --- 4. CIRCULAR TIMER (Inti Tampilan) ---
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Lingkaran Progress
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: CircularProgressIndicator(
                        value: viewModel.progress,
                        strokeWidth: 20, // Tebal seperti di gambar
                        backgroundColor: Colors.grey[200],
                        color: Colors.black, // Warna progress hitam
                        strokeCap: StrokeCap.round, // Ujung bulat
                      ),
                    ),
                    // Container Putih di tengah (biar background garis tidak menimpa angka)
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Angka Waktu
                    Text(
                      viewModel.timeString,
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w600, // Font tebal modern
                        letterSpacing: -2,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // --- 5. CONTROL BUTTONS (Group, Play/Pause, Music) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tombol Tengah (Play/Pause) - Lebih Besar
                    GestureDetector(
                      onTap: () {
                        if (viewModel.isRunning) {
                          context.read<TimerViewModel>().pauseTimer();
                        } else {
                          context.read<TimerViewModel>().startTimer();
                        }
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!, width: 2),
                          color: Colors.white,
                        ),
                        child: Icon(
                          viewModel.isRunning ? Icons.pause : Icons.play_arrow,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // --- 6. BOTTOM BUTTON (Stop Studying) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: ElevatedButton(
                      onPressed: () {
                         context.read<TimerViewModel>().stopTimer();
                         // Logic kembali ke home bisa ditaruh sini
                         Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Stop Studying",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk tombol kecil kiri/kanan
  Widget _buildCircleBtn(IconData icon, bool isActive, VoidCallback onTap) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      child: Icon(icon, color: Colors.grey[600]),
    );
  }
}
