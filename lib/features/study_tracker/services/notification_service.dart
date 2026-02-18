import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Callback handler for notification actions (must be top-level or static).
@pragma('vm:entry-point')
void _onNotificationAction(NotificationResponse response) {
  // Route the action payload to the stream so the app can react
  NotificationService._actionStreamController.add(response.payload ?? '');
}

/// NotificationService handles timer notifications with media-style controls.
/// Supports pause/resume/stop actions via notification buttons.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  Future<void>? _initFuture;

  /// Stream that emits action payloads when notification buttons are tapped.
  static final StreamController<String> _actionStreamController =
      StreamController<String>.broadcast();

  /// Listen to this stream for notification action events.
  /// Payloads: 'pause', 'resume', 'stop'
  static Stream<String> get onAction => _actionStreamController.stream;

  /// Initialize the notification service (call once at app start)
  Future<void> initialize() {
    return _initFuture ??= _doInitialize();
  }

  Future<void> _doInitialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationAction,
      onDidReceiveBackgroundNotificationResponse: _onNotificationAction,
    );
    _isInitialized = true;
  }

  /// Show or update the timer notification with action buttons.
  Future<void> showTimerNotification({
    required String title,
    required String timeRemaining,
    required bool isRunning,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      // Build action buttons based on current state
      final List<AndroidNotificationAction> actions = [];

      if (isRunning) {
        actions.add(const AndroidNotificationAction(
          'pause',
          '⏸ Pause',
          showsUserInterface: false,
          cancelNotification: false,
        ));
      } else {
        actions.add(const AndroidNotificationAction(
          'resume',
          '▶ Resume',
          showsUserInterface: false,
          cancelNotification: false,
        ));
      }

      actions.add(const AndroidNotificationAction(
        'stop',
        '⏹ Stop',
        showsUserInterface: true, // Bring app to foreground on stop
        cancelNotification: false,
      ));

      final androidDetails = AndroidNotificationDetails(
        'timer_channel',
        'Study Timer',
        channelDescription: 'Shows study timer progress with controls',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
        playSound: false,
        enableVibration: false,
        category: AndroidNotificationCategory.progress,
        actions: actions,
      );

      final details = NotificationDetails(android: androidDetails);

      final body = isRunning
          ? 'Timer running: $timeRemaining'
          : 'Paused: $timeRemaining';

      await _notifications.show(0, title, body, details);
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  /// Cancel the timer notification
  Future<void> cancelNotification() async {
    try {
      await _notifications.cancel(0);
    } catch (e) {
      debugPrint('Failed to cancel notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Failed to cancel all notifications: $e');
    }
  }

  /// Request notification permission (Android 13+ / API 33+).
  /// Call this early in the app lifecycle so the OS prompt appears once.
  Future<bool> requestPermission() async {
    try {
      if (!_isInitialized) await initialize();
      final android = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return false;
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    } catch (e) {
      debugPrint('Failed to request notification permission: $e');
      return false;
    }
  }
}
