import 'package:shared_preferences/shared_preferences.dart';

class PendingSessionService {
  static const String _keyFocusTime = 'pending_focus_time';
  static const String _keyBreakTime = 'pending_break_time';
  static const String _keyHasPending = 'has_pending_session';

  Future<void> saveSession(int focusTime, int breakTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFocusTime, focusTime);
    await prefs.setInt(_keyBreakTime, breakTime);
    await prefs.setBool(_keyHasPending, true);
  }

  Future<Map<String, int>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyHasPending) || !prefs.getBool(_keyHasPending)!) {
      return null;
    }
    return {
      'focusTime': prefs.getInt(_keyFocusTime) ?? 0,
      'breakTime': prefs.getInt(_keyBreakTime) ?? 0,
    };
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFocusTime);
    await prefs.remove(_keyBreakTime);
    await prefs.remove(_keyHasPending);
  }

  Future<bool> hasPendingSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasPending) ?? false;
  }
}
