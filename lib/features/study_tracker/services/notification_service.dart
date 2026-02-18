import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Callback handler for notification actions (must be top-level or static).
@pragma('vm:entry-point')
void _onNotificationAction(NotificationResponse response) {
  // When an action button is tapped, the button ID is in actionId.
  // When the notification body itself is tapped, use payload as fallback.
  final String action = (response.actionId != null && response.actionId!.isNotEmpty)
      ? response.actionId!
      : (response.payload ?? '');
  if (action.isNotEmpty) {
    NotificationService._actionStreamController.add(action);
  }
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

  /// Key for storing notification enabled preference
  static const String _prefKey = 'notifications_enabled';

  /// Whether notifications are enabled by the user.
  /// Defaults to true. Loaded from SharedPreferences.
  bool _enabled = true;
  bool get enabled => _enabled;

  /// Load the enabled preference from disk.
  Future<void> _loadEnabledPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_prefKey) ?? true;
    } catch (_) {
      _enabled = true;
    }
  }

  /// Set whether notifications are enabled and persist the choice.
  Future<void> setEnabled(bool value) async {
    _enabled = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, value);
    } catch (e) {
      debugPrint('Failed to save notification preference: $e');
    }
    // If user disables notifications, cancel any active one immediately
    if (!value) {
      await cancelNotification();
    }
  }

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
      '@drawable/ic_launcher_foreground',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationAction,
      onDidReceiveBackgroundNotificationResponse: _onNotificationAction,
    );
    await _loadEnabledPref();
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

      // Respect user preference — skip if notifications are disabled
      if (!_enabled) return;

      // Build action buttons based on current state
      final List<AndroidNotificationAction> actions = [];

      if (isRunning) {
        actions.add(const AndroidNotificationAction(
          'pause',
          '⏸ Pause',
          showsUserInterface: true,
          cancelNotification: false,
        ));
      } else {
        actions.add(const AndroidNotificationAction(
          'resume',
          '▶ Resume',
          showsUserInterface: true,
          cancelNotification: false,
        ));
      }

      actions.add(const AndroidNotificationAction(
        'stop',
        '⏹ Stop',
        showsUserInterface: true,
        cancelNotification: false,
      ));

      final androidDetails = AndroidNotificationDetails(
        'timer_channel',
        'Study Timer',
        channelDescription: 'Shows study timer progress with controls',
        importance: Importance.high,
        priority: Priority.high,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
        playSound: false,
        enableVibration: false,
        onlyAlertOnce: true,
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