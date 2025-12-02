import 'dart:async';
import 'package:flutter/material.dart';

// Enum untuk status sesi
enum SessionType { focus, shortBreak, longBreak }

class TimerViewModel extends ChangeNotifier {
  // --- KONFIGURASI WAKTU (Dalam Detik) ---
  int _focusDuration = 25 * 60; // Default 25 menit
  int _shortBreakDuration = 5 * 60; // 5 menit
  final int _longBreakDuration = 30 * 60; // 30 menit

  // --- STATE LAMA ---
  int _remainingSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  SessionType _sessionType = SessionType.focus;
  int _cycleCount = 0;

  // --- NEW STATE: AKUMULASI WAKTU ---
  int _totalFocusElapsed = 0; // Total detik fokus yang sudah berjalan
  int _totalBreakElapsed = 0; // Total detik istirahat yang sudah berjalan

  // --- GETTERS ---
  bool get isRunning => _isRunning;
  int get remainingSeconds => _remainingSeconds;
  SessionType get sessionType => _sessionType;
  int get cycleCount => _cycleCount;

  // Getter untuk dikirim ke PostStudyPage
  int get totalFocusElapsed => _totalFocusElapsed;
  int get totalBreakElapsed => _totalBreakElapsed;

  int get focusMinutes => _focusDuration ~/ 60;
  int get shortBreakMinutes => _shortBreakDuration ~/ 60;
  
  // Mendapatkan durasi tot al saat ini (untuk progress bar)
  int get currentTotalDuration {
    switch (_sessionType) {
      case SessionType.focus: return _focusDuration;
      case SessionType.shortBreak: return _shortBreakDuration;
      case SessionType.longBreak: return _longBreakDuration;
    }
  }

  double get progress => _remainingSeconds / currentTotalDuration;

  String get timeString {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // --- LOGIKA UTAMA ---

  void startTimer() {
    if (_timer != null) return;
    _isRunning = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        // --- LOGIKA BARU: Tambahkan ke total akumulasi ---
        if (_sessionType == SessionType.focus) {
          _totalFocusElapsed++;
        } else {
          _totalBreakElapsed++;
        }
        notifyListeners();
      } else {
        _handleTimerComplete();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  void setCustomFocusTime(int minutes) {
    if (minutes < 1 || minutes > 180) return; // Batas 1 - 180 menit

    _focusDuration = minutes * 60;
    // Update timer realtime jika sedang di mode focus & pause
    if (_sessionType == SessionType.focus && !_isRunning) {
      _remainingSeconds = _focusDuration;
    }
    notifyListeners();
  }

  void setCustomShortBreakTime(int minutes) {
    if (minutes < 1 || minutes > 60) return; // Batas 1 - 60 menit

    _shortBreakDuration = minutes * 60;
    // Update timer realtime jika sedang di mode break & pause
    if (_sessionType == SessionType.shortBreak && !_isRunning) {
      _remainingSeconds = _shortBreakDuration;
    }
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _resetToCurrentSessionStart(); // Reset ke awal sesi saat ini
    notifyListeners();
  }

  // --- LOGIKA SIKLUS ---
  void _handleTimerComplete() {
    // 1. Matikan objek timer yang lama (tapi JANGAN ubah _isRunning jadi false)
    _timer?.cancel();
    _timer = null;

    // 2. Tentukan sesi berikutnya & Reset Waktu
    if (_sessionType == SessionType.focus) {
      // Sesi FOKUS selesai -> Lanjut ke BREAK
      _cycleCount++;
      
      if (_cycleCount % 4 == 0) {
        _sessionType = SessionType.longBreak; 
        _remainingSeconds = _longBreakDuration;
      } else {
        _sessionType = SessionType.shortBreak; 
        _remainingSeconds = _shortBreakDuration;
      }
    } else {
      // Sesi BREAK selesai -> Lanjut ke FOKUS
      _sessionType = SessionType.focus;
      _remainingSeconds = _focusDuration;
    }
    
    // 3. PENTING: Langsung panggil startTimer() lagi!
    // Karena _timer sudah di-null-kan di langkah 1, fungsi startTimer akan membuat timer baru.
    // Status _isRunning tetap true, jadi UI tombol tetap "Pause".
    startTimer(); 
    
    notifyListeners();
  }

  void _resetToCurrentSessionStart() {
    switch (_sessionType) {
      case SessionType.focus: _remainingSeconds = _focusDuration; break;
      case SessionType.shortBreak: _remainingSeconds = _shortBreakDuration; break;
      case SessionType.longBreak: _remainingSeconds = _longBreakDuration; break;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}