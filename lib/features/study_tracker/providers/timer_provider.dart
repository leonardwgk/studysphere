import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../data/session_type.dart';

class TimerProvider with ChangeNotifier {
  // Pengaturan Waktu (Menit) - dengan batas validasi
  static const int minFocusMinutes = 1;
  static const int maxFocusMinutes = 120;
  static const int minBreakMinutes = 1;
  static const int maxBreakMinutes = 60;

  int _focusMinutes = 25;
  int _shortBreakMinutes = 5;

  // State Timer
  Timer? _timer;
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  SessionType _sessionType = SessionType.focus;

  // Iterasi Pomodoro (Track berapa kali focus selesai)
  int _currentIteration = 1;
  static const int iterationsBeforeLongBreak = 4;

  // Statistik Sesi (Untuk dikirim ke PostStudyPage)
  int _totalFocusElapsed = 0;
  int _totalBreakElapsed = 0;
  int _completedPomodoros = 0; // Jumlah pomodoro yang selesai penuh

  // variabel subjek dan daftar kategori
  String _subject = "Matematika";
  final List<String> _categories = [
    "Matematika",
    "Fisika",
    "Biologi",
    "Kimia",
    "Sejarah",
    "Bahasa Inggris",
    "Bahasa Indonesia",
    "Lainnya",
  ];

  // Getters
  int get focusMinutes => _focusMinutes;
  int get shortBreakMinutes => _shortBreakMinutes;
  bool get isRunning => _isRunning;
  SessionType get sessionType => _sessionType;
  int get totalFocusElapsed => _totalFocusElapsed;
  int get totalBreakElapsed => _totalBreakElapsed;
  String get subject => _subject;
  List<String> get categories => _categories;
  int get currentIteration => _currentIteration;
  int get completedPomodoros => _completedPomodoros;

  void setSubject(String newSubject) {
    _subject = newSubject;
    notifyListeners();
  }

  double get progress {
    int total = _sessionType == SessionType.focus
        ? _focusMinutes * 60
        : _shortBreakMinutes * 60;
    return (_secondsRemaining / total).clamp(0.0, 1.0);
  }

  String get timeString {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Pengaturan Waktu Custom dengan Validasi
  void setCustomFocusTime(int mins) {
    if (mins < minFocusMinutes || mins > maxFocusMinutes) return;
    _focusMinutes = mins;
    if (!_isRunning && _sessionType == SessionType.focus) {
      _secondsRemaining = _focusMinutes * 60;
    }
    notifyListeners();
  }

  void setCustomShortBreakTime(int mins) {
    if (mins < minBreakMinutes || mins > maxBreakMinutes) return;
    _shortBreakMinutes = mins;
    if (!_isRunning && _sessionType != SessionType.focus) {
      _secondsRemaining = _shortBreakMinutes * 60;
    }
    notifyListeners();
  }

  // Validasi: Cek apakah nilai bisa dikurangi/ditambah
  bool canDecreaseFocus() => _focusMinutes > minFocusMinutes;
  bool canIncreaseFocus() => _focusMinutes < maxFocusMinutes;
  bool canDecreaseBreak() => _shortBreakMinutes > minBreakMinutes;
  bool canIncreaseBreak() => _shortBreakMinutes < maxBreakMinutes;

  // Kontrol Timer
  void startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        if (_sessionType == SessionType.focus) {
          _totalFocusElapsed++;
        } else {
          _totalBreakElapsed++;
        }
        notifyListeners();
      } else {
        _handleSessionSwitch();
      }
    });
    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    // Reset timer ke durasi awal sesuai tipe sesi
    _secondsRemaining = _sessionType == SessionType.focus
        ? _focusMinutes * 60
        : _shortBreakMinutes * 60;
    notifyListeners();
  }

  Future<void> _handleSessionSwitch() async {
    pauseTimer();

    // Trigger vibration untuk notifikasi transisi
    if (await Vibration.hasVibrator()) {
      // Pattern: vibrate-pause-vibrate untuk notifikasi yang jelas
      Vibration.vibrate(pattern: [0, 500, 200, 500]);
    }

    if (_sessionType == SessionType.focus) {
      // Focus selesai -> pindah ke break
      _completedPomodoros++;
      _sessionType = SessionType.shortBreak;
      _secondsRemaining = _shortBreakMinutes * 60;
    } else {
      // Break selesai -> pindah ke focus berikutnya
      _currentIteration++;
      _sessionType = SessionType.focus;
      _secondsRemaining = _focusMinutes * 60;
    }
    notifyListeners();
  }

  // Reset semua state (untuk sesi baru)
  void resetAll() {
    _timer?.cancel();
    _isRunning = false;
    _sessionType = SessionType.focus;
    _secondsRemaining = _focusMinutes * 60;
    _totalFocusElapsed = 0;
    _totalBreakElapsed = 0;
    _currentIteration = 1;
    _completedPomodoros = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
