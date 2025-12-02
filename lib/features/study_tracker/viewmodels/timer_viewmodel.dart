import 'dart:async';
import 'package:flutter/material.dart';

class TimerViewModel extends ChangeNotifier {
  // --- STATE ---
  static const int _defaultDuration = 60 * 60; // Misal 1 jam (sesuai gambar 53:21)
  int _remainingSeconds = 10; // Contoh: 53 menit 21 detik
  int get totalDuration => _defaultDuration; // Untuk progress bar

  Timer? _timer;
  bool _isRunning = false;
  String _subject = "Fluid Mechanics";

  // --- GETTERS (Data yang dibaca UI) ---
  bool get isRunning => _isRunning;
  int get remainingSeconds => _remainingSeconds;
  String get subject => _subject;
  double get progress => _remainingSeconds / _defaultDuration;

  String get timeString {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // --- ACTIONS (Perintah dari UI) ---
  
  void startTimer() {
    if (_timer != null) return;
    _isRunning = true;
    notifyListeners(); // Kabari UI untuk update icon jadi Pause

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners(); // Kabari UI untuk update angka waktu
      } else {
        stopTimer();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _remainingSeconds = _defaultDuration; // Reset
    notifyListeners();
    // Di sini nanti panggil Service untuk simpan ke Firebase
  }

  // Ubah mata pelajaran
  void updateSubject(String newSubject) {
    _subject = newSubject;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

