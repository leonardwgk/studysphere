import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/session_type.dart';

class TimerProvider with ChangeNotifier {
  // Pengaturan Waktu (Menit)
  int _focusMinutes = 25;
  int _shortBreakMinutes = 5;
  
  // State Timer
  Timer? _timer;
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  SessionType _sessionType = SessionType.focus;

  // Statistik Sesi (Untuk dikirim ke PostStudyPage)
  int _totalFocusElapsed = 0;
  int _totalBreakElapsed = 0;

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
    "Lainnya"
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

  // Pengaturan Waktu Custom
  void setCustomFocusTime(int mins) {
    if (mins < 1) return;
    _focusMinutes = mins;
    if (!_isRunning && _sessionType == SessionType.focus) {
      _secondsRemaining = _focusMinutes * 60;
    }
    notifyListeners();
  }

  void setCustomShortBreakTime(int mins) {
    if (mins < 1) return;
    _shortBreakMinutes = mins;
    if (!_isRunning && _sessionType != SessionType.focus) {
      _secondsRemaining = _shortBreakMinutes * 60;
    }
    notifyListeners();
  }

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

  void _handleSessionSwitch() {
    pauseTimer();
    if (_sessionType == SessionType.focus) {
      _sessionType = SessionType.shortBreak;
      _secondsRemaining = _shortBreakMinutes * 60;
    } else {
      _sessionType = SessionType.focus;
      _secondsRemaining = _focusMinutes * 60;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}