import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../providers/timer_provider.dart';
import '../data/session_type.dart';
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

    // UI Logic untuk warna berdasarkan session type
    final bool isFocusMode = tp.sessionType == SessionType.focus;
    Color themeColor = isFocusMode ? Colors.black : Colors.green;
    Color backgroundColor = isFocusMode
        ? Colors.white
        : const Color(0xFFE8F5E9);
    String statusText = isFocusMode ? "Focus Time" : "Break Time";

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, tp),
                const SizedBox(height: 10),
                _buildIterationBadge(tp),
                const SizedBox(height: 10),
                _buildSubjectTitle(context, tp),
                const Spacer(),
                _buildTimerCircle(tp, themeColor, statusText),
                const Spacer(),
                _buildControls(context, tp, themeColor),
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
        child: Image.asset(
          'assets/images/wavy_bg.png',
          fit: BoxFit.cover,
          errorBuilder: (c, o, s) => Container(),
        ),
      ),
    );
  }

  Widget _buildIterationBadge(TimerProvider tp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.loop, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            "Pomodoro #${tp.currentIteration}",
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (tp.completedPomodoros > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "✓ ${tp.completedPomodoros}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
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
            onPressed: () => _handleBackButton(context, tp),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: tp.isRunning ? Colors.grey[400] : Colors.black,
            ),
            onPressed: tp.isRunning ? null : () => _showSettings(context, tp),
          ),
        ],
      ),
    );
  }

  void _handleBackButton(BuildContext context, TimerProvider tp) {
    if (tp.totalFocusElapsed > 0 || tp.totalBreakElapsed > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Keluar dari Sesi?"),
          content: const Text(
            "Progress belajar Anda akan hilang jika keluar sekarang.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("Ya, Keluar"),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildSubjectTitle(BuildContext context, TimerProvider tp) {
    return GestureDetector(
      onTap: () => _showSubjectPicker(context, tp), // Klik untuk ganti
      child: Column(
        children: [
          const Text(
            "#Individually Studying",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tp.subject,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              const Text(
                "Pilih Mata Pelajaran",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
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
          width: 280,
          height: 280,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tp.timeString,
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls(
    BuildContext context,
    TimerProvider tp,
    Color themeColor,
  ) {
    return GestureDetector(
      onTap: () async {
        if (tp.isRunning) {
          tp.pauseTimer();
        } else {
          // Vibrate on start
          if (await Vibration.hasVibrator()) {
            Vibration.vibrate(duration: 50);
          }
          tp.startTimer();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: themeColor,
          shape: BoxShape.circle,
          boxShadow: tp.isRunning
              ? [
                  BoxShadow(
                    color: themeColor.withValues(alpha: .4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          tp.isRunning ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          "Finish Session",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- LOGIC FUNCTIONS ---

  void _handleStop(BuildContext context, TimerProvider tp) {
    // Validasi: Jika belum ada waktu focus sama sekali
    if (tp.totalFocusElapsed == 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Belum Ada Sesi"),
          content: const Text(
            "Anda belum memulai focus time. Mulai timer terlebih dahulu sebelum menyelesaikan sesi.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Mengerti"),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Selesaikan Sesi?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ringkasan sesi Anda:"),
            const SizedBox(height: 12),
            _buildSummaryRow(
              Icons.timer,
              "Focus Time",
              _formatDuration(tp.totalFocusElapsed),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              Icons.coffee,
              "Break Time",
              _formatDuration(tp.totalBreakElapsed),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              Icons.check_circle,
              "Pomodoro Selesai",
              "${tp.completedPomodoros}",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              int focus = tp.totalFocusElapsed;
              int breakTime = tp.totalBreakElapsed;
              String subject = tp.subject;
              tp.stopTimer();
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PostStudyPage(
                    totalFocusTime: focus,
                    totalBreakTime: breakTime,
                    initialLabel: subject,
                  ),
                ),
              );
            },
            child: const Text("Ya, Selesai"),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey[600])),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatDuration(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    if (mins > 0) {
      return "${mins}m ${secs}s";
    }
    return "${secs}s";
  }

  void _showSettings(BuildContext context, TimerProvider tp) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => ChangeNotifierProvider.value(
        value: tp,
        child: Consumer<TimerProvider>(
          builder: (context, vm, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Pengaturan Timer",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Focus: ${TimerProvider.minFocusMinutes}-${TimerProvider.maxFocusMinutes} menit | Break: ${TimerProvider.minBreakMinutes}-${TimerProvider.maxBreakMinutes} menit",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 20),
                _buildTimePicker(
                  "Focus Duration",
                  vm.focusMinutes,
                  (v) => vm.setCustomFocusTime(v),
                  canDecrease: vm.canDecreaseFocus(),
                  canIncrease: vm.canIncreaseFocus(),
                ),
                const SizedBox(height: 12),
                _buildTimePicker(
                  "Break Duration",
                  vm.shortBreakMinutes,
                  (v) => vm.setCustomShortBreakTime(v),
                  canDecrease: vm.canDecreaseBreak(),
                  canIncrease: vm.canIncreaseBreak(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    String title,
    int value,
    Function(int) onChanged, {
    required bool canDecrease,
    required bool canIncrease,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.remove,
                color: canDecrease ? Colors.black : Colors.grey[300],
              ),
              onPressed: canDecrease ? () => onChanged(value - 1) : null,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$value min",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.add,
                color: canIncrease ? Colors.black : Colors.grey[300],
              ),
              onPressed: canIncrease ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}
