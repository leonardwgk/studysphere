import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/timer_viewmodel.dart';
import 'post_study_page.dart'; // Import halaman tujuan

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerViewModel(),
      child: const _PomodoroView(),
    );
  }
}

class _PomodoroView extends StatelessWidget {
  const _PomodoroView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TimerViewModel>();

    // Menentukan teks status berdasarkan sesi
    String statusText;
    Color statusColor;
    
    if (viewModel.sessionType == SessionType.focus) {
      statusText = "Focus Time";
      statusColor = Colors.black;
    } else if (viewModel.sessionType == SessionType.shortBreak) {
      statusText = "Short Break";
      statusColor = Colors.green;
    } else {
      statusText = "Long Break";
      statusColor = Colors.blue;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image (Opsional)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset('assets/images/wavy_bg.png', fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => Container(color: Colors.white)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // --- HEADER & CUSTOM SETTINGS ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol Custom Time (Fitur No. 2)
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () => _showCustomTimeSheet(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // --- STATUS TEXT ---
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor, 
                    fontSize: 24, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 40),

                // --- TIMER CIRCLE ---
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: CircularProgressIndicator(
                        value: viewModel.progress,
                        strokeWidth: 20,
                        backgroundColor: Colors.grey[100],
                        color: statusColor, // Warna berubah sesuai status
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      viewModel.timeString,
                      style: const TextStyle(
                        fontSize: 64, 
                        fontWeight: FontWeight.w600,
                        letterSpacing: -2,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // --- CONTROL BUTTONS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Play / Pause
                    GestureDetector(
                      onTap: () {
                        if (viewModel.isRunning) {
                          context.read<TimerViewModel>().pauseTimer();
                        } else {
                          context.read<TimerViewModel>().startTimer();
                        }
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Icon(
                          viewModel.isRunning ? Icons.pause : Icons.play_arrow,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),

                // --- STOP BUTTON (Fitur No. 3 & 4) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: OutlinedButton(
                    onPressed: () => _handleStop(context), // Panggil fungsi stop
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Finish Session",
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.red
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

  // --- LOGIKA ALERT STOP (Fitur No. 3 & 4) ---
  void _handleStop(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hentikan Sesi?"),
        content: const Text("Sesi Pomodoro akan dihentikan dan Anda akan diarahkan ke halaman upload."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Batal
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // 1. Ambil data statistik DARI ViewModel SEBELUM di-stop total
              final viewModel = context.read<TimerViewModel>();
              final int finalFocusTime = viewModel.totalFocusElapsed;
              final int finalBreakTime = viewModel.totalBreakElapsed;
              
              // 2. Matikan timer
              viewModel.stopTimer();
              
              // 3. Tutup Dialog
              Navigator.pop(ctx);
              
              // 3. Pindah ke Halaman Upload (Fitur No. 4)
              Navigator.pushReplacement(
              context, 
              MaterialPageRoute(
                builder: (context) => PostStudyPage(
                  totalFocusTime: finalFocusTime,
                  totalBreakTime: finalBreakTime,
                ),
              ),
            );
            },
            child: const Text("Finish", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- LOGIKA CUSTOM TIME (Fitur No. 2) ---
  void _showCustomTimeSheet(BuildContext context) {
    // 1. TANGKAP ViewModel dari luar
    final outerViewModel = context.read<TimerViewModel>();
    
    if (outerViewModel.isRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pause timer dulu untuk mengubah waktu."))
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))
      ),
      builder: (ctx) {
        // 2. PASTI BERHASIL: Gunakan ChangeNotifierProvider.value
        return ChangeNotifierProvider.value(
          value: outerViewModel,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300], 
                    borderRadius: BorderRadius.circular(2)
                  ),
                ),
                
                const Text(
                  "Pengaturan Waktu", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 30),

                // 3. GUNAKAN CONSUMER AGAR ANGKA BERUBAH REALTIME DI DALAM SHEET
                Consumer<TimerViewModel>(
                  builder: (context, vm, child) {
                    return Column(
                      children: [
                        // --- INPUT WAKTU FOKUS ---
                        _buildTimeCounter(
                          title: "Durasi Fokus",
                          value: vm.focusMinutes,
                          onDecrement: () => vm.setCustomFocusTime(vm.focusMinutes - 5), // Kurang 5 menit
                          onIncrement: () => vm.setCustomFocusTime(vm.focusMinutes + 5), // Tambah 5 menit
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Divider(),
                        ),

                        // --- INPUT WAKTU ISTIRAHAT ---
                        _buildTimeCounter(
                          title: "Istirahat Pendek",
                          value: vm.shortBreakMinutes,
                          onDecrement: () => vm.setCustomShortBreakTime(vm.shortBreakMinutes - 1), // Kurang 1 menit
                          onIncrement: () => vm.setCustomShortBreakTime(vm.shortBreakMinutes + 1), // Tambah 1 menit
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeCounter({
    required String title, 
    required int value, 
    required VoidCallback onDecrement, 
    required VoidCallback onIncrement
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title, 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Tombol Minus
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: onDecrement,
                color: Colors.black,
              ),
              
              // Angka Menit
              Container(
                width: 50,
                alignment: Alignment.center,
                child: Text(
                  "$value m",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              
              // Tombol Plus
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: onIncrement,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ],
    );
  }
}