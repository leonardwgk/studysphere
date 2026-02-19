import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../providers/timer_provider.dart';
import '../data/session_type.dart';
import '../services/notification_service.dart';
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

class _PomodoroView extends StatefulWidget {
  const _PomodoroView();

  @override
  State<_PomodoroView> createState() => _PomodoroViewState();
}

class _PomodoroViewState extends State<_PomodoroView>
    with WidgetsBindingObserver {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationService.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Cancel notification when leaving the page
    _notificationService.cancelNotification();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final tp = context.read<TimerProvider>();

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App going to background — show persistent notification if timer active
      if (tp.isRunning || tp.totalFocusElapsed > 0) {
        tp.forceUpdateNotification();
      }
    } else if (state == AppLifecycleState.resumed) {
      // App back to foreground — notification stays for controls but
      // we could optionally dismiss it here. Keep it for consistency.
    }
  }

  // Color scheme for different session types
  static const Color _focusColor = Color(0xFFFF6B6B); // Warm red-orange
  static const Color _focusBgColor = Color(0xFFFFE8E8); // Light red bg
  static const Color _shortBreakColor = Color(0xFF4ECDC4); // Teal
  static const Color _shortBreakBgColor = Color(0xFFE8F8F7); // Light teal bg
  static const Color _longBreakColor = Color(0xFF45B7D1); // Deep blue
  static const Color _longBreakBgColor = Color(0xFFE8F4F8); // Light blue bg
  // Neutral color for initial state (before timer started)
  static const Color _neutralColor = Color(0xFF6B7280); // Gray
  static const Color _neutralBgColor = Color(0xFFF3F4F6); // Light gray bg

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TimerProvider>();

    // Check if timer has ever been started (totalFocusElapsed or isRunning indicates activity)
    final bool hasStarted = tp.totalFocusElapsed > 0 || tp.isRunning;

    // Dynamic colors based on session type
    final Color themeColor;
    final Color backgroundColor;
    final String statusText;

    // Show neutral colors before timer has started for the first time
    if (!hasStarted && tp.sessionType == SessionType.focus) {
      themeColor = _neutralColor;
      backgroundColor = _neutralBgColor;
      statusText = "Ready to Focus";
    } else {
      switch (tp.sessionType) {
        case SessionType.focus:
          themeColor = _focusColor;
          backgroundColor = tp.isRunning ? _focusBgColor : Colors.white;
          statusText = tp.isRunning ? "Focus Time" : "Paused";
          break;
        case SessionType.shortBreak:
          themeColor = _shortBreakColor;
          backgroundColor = tp.isRunning ? _shortBreakBgColor : Colors.white;
          statusText = tp.isRunning ? "Short Break" : "Paused";
          break;
        case SessionType.longBreak:
          themeColor = _longBreakColor;
          backgroundColor = tp.isRunning ? _longBreakBgColor : Colors.white;
          statusText = tp.isRunning ? "Long Break" : "Paused";
          break;
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackButton(context, tp);
      },
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [backgroundColor, backgroundColor.withValues(alpha: 0.7)],
            ),
          ),
          child: Stack(
            children: [
              _buildBackground(),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, tp, themeColor),
                    const SizedBox(height: 4),
                    _buildIterationBadge(tp, themeColor),
                    const SizedBox(height: 8),
                    _buildSubjectTitle(context, tp),
                    const Spacer(),
                    _buildTimerCircle(tp, themeColor, statusText),
                    const SizedBox(height: 12),
                    _buildNextSessionHint(tp, hasStarted),
                    const Spacer(),
                    _buildControls(context, tp, themeColor),
                    const SizedBox(height: 20),
                    _buildBottomActions(context, tp),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildIterationBadge(TimerProvider tp, Color themeColor) {
    final int cycleProgress =
        tp.completedPomodoros % TimerProvider.iterationsBeforeLongBreak;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Pomodoro #${tp.currentIteration}",
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          // Progress dots for the 4-pomodoro cycle
          ...List.generate(TimerProvider.iterationsBeforeLongBreak, (i) {
            final bool completed = i < cycleProgress;
            final bool current =
                i == cycleProgress && tp.sessionType == SessionType.focus;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: current ? 14 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: completed
                      ? themeColor
                      : current
                          ? themeColor.withValues(alpha: 0.5)
                          : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    TimerProvider tp,
    Color themeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => _handleBackButton(context, tp),
          ),
          // Total study elapsed time badge
          if (tp.totalFocusElapsed > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined,
                      size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(tp.totalFocusElapsed),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(),
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
                tp.stopTimer();
                _notificationService.cancelNotification();
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
          try {
            if (await Vibration.hasVibrator()) {
              Vibration.vibrate(duration: 50);
            }
          } catch (_) {}
          if (!context.mounted) return;
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

  void _confirmSkipBreak(BuildContext context, TimerProvider tp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Skip Break?"),
        content: const Text(
          "Are you sure you want to skip this break and start the next focus session?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              tp.skipBreak();
              Navigator.pop(ctx);
            },
            child: const Text("Skip Break"),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, TimerProvider tp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (tp.isBreakSession) ...[
            _buildActionChip(
              icon: Icons.skip_next_rounded,
              label: "Skip",
              onTap: () => _confirmSkipBreak(context, tp),
              color: Colors.grey[700]!,
            ),
            const SizedBox(width: 16),
          ],
          _buildActionChip(
            icon: Icons.flag_rounded,
            label: "Finish",
            onTap: () => _handleStop(context, tp),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextSessionHint(TimerProvider tp, bool hasStarted) {
    if (!hasStarted) {
      return Text(
        "Tap ▶ to begin your session",
        style: TextStyle(color: Colors.grey[500], fontSize: 13),
      );
    }

    final String nextLabel;
    final Color nextColor;
    final String nextDuration;

    if (tp.sessionType == SessionType.focus) {
      final nextCompleted = tp.completedPomodoros + 1;
      if (nextCompleted % TimerProvider.iterationsBeforeLongBreak == 0) {
        nextLabel = "Long Break";
        nextColor = _longBreakColor;
        nextDuration = "${tp.longBreakMinutes}min";
      } else {
        nextLabel = "Short Break";
        nextColor = _shortBreakColor;
        nextDuration = "${tp.shortBreakMinutes}min";
      }
    } else {
      nextLabel = "Focus #${tp.currentIteration + 1}";
      nextColor = _focusColor;
      nextDuration = "${tp.focusMinutes}min";
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.arrow_forward_rounded,
            size: 14, color: nextColor.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Text(
          "Next: $nextLabel · $nextDuration",
          style: TextStyle(
            color: nextColor.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
              _notificationService.cancelNotification();
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
                  "Focus: ${TimerProvider.minFocusMinutes}-${TimerProvider.maxFocusMinutes} min | Short Break: ${TimerProvider.minBreakMinutes}-${TimerProvider.maxBreakMinutes} min | Long Break: ${TimerProvider.minLongBreakMinutes}-${TimerProvider.maxLongBreakMinutes} min",
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildTimePicker(
                  context,
                  "Focus Duration",
                  vm.focusMinutes,
                  (v) => vm.setCustomFocusTime(v),
                  minValue: TimerProvider.minFocusMinutes,
                  maxValue: TimerProvider.maxFocusMinutes,
                ),
                const SizedBox(height: 12),
                _buildTimePicker(
                  context,
                  "Short Break",
                  vm.shortBreakMinutes,
                  (v) => vm.setCustomShortBreakTime(v),
                  minValue: TimerProvider.minBreakMinutes,
                  maxValue: TimerProvider.maxBreakMinutes,
                ),
                const SizedBox(height: 12),
                _buildTimePicker(
                  context,
                  "Long Break",
                  vm.longBreakMinutes,
                  (v) => vm.setCustomLongBreakTime(v),
                  minValue: TimerProvider.minLongBreakMinutes,
                  maxValue: TimerProvider.maxLongBreakMinutes,
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
    BuildContext context,
    String title,
    int value,
    Function(int) onChanged, {
    required int minValue,
    required int maxValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        GestureDetector(
          onTap: () => _showTimeInputDialog(
            context,
            title,
            value,
            minValue,
            maxValue,
            onChanged,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$value min",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.edit, size: 16, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTimeInputDialog(
    BuildContext context,
    String title,
    int currentValue,
    int minValue,
    int maxValue,
    Function(int) onChanged,
  ) {
    final controller = TextEditingController(text: currentValue.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Set $title",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter duration ($minValue - $maxValue minutes)",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  suffixText: "min",
                  suffixStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a value";
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null) {
                    return "Enter a valid number";
                  }
                  if (parsed < minValue || parsed > maxValue) {
                    return "Must be $minValue - $maxValue";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newValue = int.parse(controller.text);
                onChanged(newValue);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
