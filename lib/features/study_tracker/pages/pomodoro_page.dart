import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../data/models/session_type.dart';
import 'post_study_page.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerProvider(),
      child: const _PomodoroView(),
    );
  }
}

class _PomodoroView extends StatelessWidget {
  const _PomodoroView();

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TimerProvider>();

    // UI Logic untuk warna
    Color themeColor = tp.sessionType == SessionType.focus ? Colors.black : Colors.green;
    String statusText = tp.sessionType == SessionType.focus ? "Focus Time" : "Short Break";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, tp),
                const SizedBox(height: 20),
                _buildSubjectTitle(context, tp),
                const Spacer(),
                _buildTimerCircle(tp, themeColor, statusText),
                const Spacer(),
                _buildControls(context, tp),
                const SizedBox(height: 20),
                _buildStopButton(context, tp),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildBackground() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.05,
        child: Image.asset('assets/images/wavy_bg.png', fit: BoxFit.cover,
            errorBuilder: (c, o, s) => Container(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TimerProvider tp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context, tp),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTitle(BuildContext context, TimerProvider tp) {
    return GestureDetector(
      onTap: () => _showSubjectPicker(context, tp), // Klik untuk ganti
      child: Column(
        children: [
          const Text("#Individually Studying", 
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(tp.subject, 
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  void _showSubjectPicker(BuildContext context, TimerProvider tp) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (ctx) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Pilih Mata Pelajaran", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // List daftar kategori dari Provider
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tp.categories.length,
                itemBuilder: (context, index) {
                  final cat = tp.categories[index];
                  return ListTile(
                    title: Text(cat),
                    trailing: tp.subject == cat 
                        ? const Icon(Icons.check_circle, color: Colors.black) 
                        : null,
                    onTap: () {
                      tp.setSubject(cat);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildTimerCircle(TimerProvider tp, Color color, String status) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 280, height: 280,
          child: CircularProgressIndicator(
            value: tp.progress,
            strokeWidth: 15,
            backgroundColor: Colors.grey[100],
            color: color,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
            Text(tp.timeString, 
                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, TimerProvider tp) {
    return GestureDetector(
      onTap: () => tp.isRunning ? tp.pauseTimer() : tp.startTimer(),
      child: Container(
        width: 80, height: 80,
        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        child: Icon(tp.isRunning ? Icons.pause : Icons.play_arrow, 
            color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildStopButton(BuildContext context, TimerProvider tp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: () => _handleStop(context, tp),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text("Finish Session", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- LOGIC FUNCTIONS ---

  void _handleStop(BuildContext context, TimerProvider tp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hentikan Sesi?"),
        content: const Text("Data belajar Anda akan disimpan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              int focus = tp.totalFocusElapsed;
              int breakTime = tp.totalBreakElapsed;
              tp.stopTimer();
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (_) => PostStudyPage(
                  totalFocusTime: focus, 
                  totalBreakTime: breakTime,
                  initialLabel: tp.subject,
                ))
              );
            },
            child: const Text("Ya, Selesai"),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context, TimerProvider tp) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => ChangeNotifierProvider.value(
        value: tp,
        child: Consumer<TimerProvider>(
          builder: (context, vm, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildTimePicker("Focus Duration", vm.focusMinutes, (v) => vm.setCustomFocusTime(v)),
                _buildTimePicker("Break Duration", vm.shortBreakMinutes, (v) => vm.setCustomShortBreakTime(v)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(String title, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.remove), onPressed: () => onChanged(value - 1)),
            Text("$value min", style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.add), onPressed: () => onChanged(value + 1)),
          ],
        )
      ],
    );
  }
}