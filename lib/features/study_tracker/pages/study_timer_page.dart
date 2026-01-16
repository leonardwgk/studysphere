import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../data/session_type.dart';

class StudyTimerPage extends StatelessWidget {
  const StudyTimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Memastikan kita menggunakan Provider yang sudah ada di context
    final tp = context.watch<TimerProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _handleExit(context, tp);
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tp.sessionType == SessionType.focus
                    ? "Focusing..."
                    : "Breaking...",
              ),
              Text(
                tp.timeString,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _handleExit(context, tp),
                child: const Text("Stop Studying"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleExit(BuildContext context, TimerProvider tp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Stop Studying?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              tp.stopTimer();
              Navigator.pop(ctx); // Tutup dialog
              Navigator.pop(context); // Kembali ke Home
            },
            child: const Text("Stop"),
          ),
        ],
      ),
    );
  }
}
