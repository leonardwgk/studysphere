import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// NotificationService handles timer notifications when app is in background.
/// Only supports Android - iOS implementation not included.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service (call once at app start)
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);
    _isInitialized = true;
  }

  /// Show or update the timer notification
  Future<void> showTimerNotification({
    required String title,
    required String timeRemaining,
    required bool isRunning,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'timer_channel',
      'Study Timer',
      channelDescription: 'Shows study timer progress',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      category: AndroidNotificationCategory.progress,
    );

    const details = NotificationDetails(android: androidDetails);

    final body = isRunning
        ? 'Timer running: $timeRemaining'
        : 'Paused: $timeRemaining';

    await _notifications.show(
      0, // notification id
      title,
      body,
      details,
    );
  }

  /// Cancel the timer notification
  Future<void> cancelNotification() async {
    await _notifications.cancel(0);
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
