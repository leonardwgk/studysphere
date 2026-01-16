// test/features/study_tracker/providers/timer_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:studysphere_app/features/study_tracker/providers/timer_provider.dart';
import 'package:studysphere_app/features/study_tracker/data/session_type.dart';

void main() {
  group('TimerProvider', () {
    late TimerProvider timerProvider;

    setUp(() {
      timerProvider = TimerProvider(enableNotifications: false);
    });

    tearDown(() {
      timerProvider.dispose();
    });

    group('Initial State', () {
      test('has correct default values', () {
        expect(timerProvider.isRunning, false);
        expect(timerProvider.focusMinutes, 25);
        expect(timerProvider.shortBreakMinutes, 5);
        expect(timerProvider.sessionType, SessionType.focus);
        expect(timerProvider.currentIteration, 1);
        expect(timerProvider.completedPomodoros, 0);
        expect(timerProvider.totalFocusElapsed, 0);
        expect(timerProvider.totalBreakElapsed, 0);
      });

      test('timeString shows correct initial format', () {
        expect(timerProvider.timeString, '25:00');
      });

      test('progress starts at 1.0 (full)', () {
        expect(timerProvider.progress, 1.0);
      });
    });

    group('Timer Controls', () {
      test('startTimer sets isRunning to true', () {
        timerProvider.startTimer();
        expect(timerProvider.isRunning, true);
      });

      test('pauseTimer sets isRunning to false', () {
        timerProvider.startTimer();
        timerProvider.pauseTimer();
        expect(timerProvider.isRunning, false);
      });

      test('stopTimer resets seconds but keeps settings', () {
        timerProvider.setCustomFocusTime(30);
        timerProvider.startTimer();
        timerProvider.stopTimer();

        expect(timerProvider.isRunning, false);
        expect(timerProvider.timeString, '30:00');
      });

      test('startTimer is idempotent (calling twice has no effect)', () {
        timerProvider.startTimer();
        timerProvider.startTimer();
        expect(timerProvider.isRunning, true);
      });
    });

    group('Custom Time Settings', () {
      test('setCustomFocusTime updates focus duration', () {
        timerProvider.setCustomFocusTime(45);
        expect(timerProvider.focusMinutes, 45);
        expect(timerProvider.timeString, '45:00');
      });

      test('setCustomShortBreakTime updates break duration', () {
        timerProvider.setCustomShortBreakTime(10);
        expect(timerProvider.shortBreakMinutes, 10);
      });

      test('setCustomFocusTime ignores invalid values below minimum', () {
        timerProvider.setCustomFocusTime(0); // Below min (1)
        expect(timerProvider.focusMinutes, 25); // Should stay at default
      });

      test('setCustomFocusTime ignores values above maximum', () {
        timerProvider.setCustomFocusTime(200); // Above max (120)
        expect(timerProvider.focusMinutes, 25); // Should stay at default
      });

      test('setCustomShortBreakTime ignores invalid values', () {
        timerProvider.setCustomShortBreakTime(0);
        expect(timerProvider.shortBreakMinutes, 5);

        timerProvider.setCustomShortBreakTime(100); // Above max (60)
        expect(timerProvider.shortBreakMinutes, 5);
      });

      test('canDecreaseFocus returns correct value', () {
        timerProvider.setCustomFocusTime(1);
        expect(timerProvider.canDecreaseFocus(), false);

        timerProvider.setCustomFocusTime(25);
        expect(timerProvider.canDecreaseFocus(), true);
      });

      test('canIncreaseFocus returns correct value', () {
        timerProvider.setCustomFocusTime(120);
        expect(timerProvider.canIncreaseFocus(), false);

        timerProvider.setCustomFocusTime(25);
        expect(timerProvider.canIncreaseFocus(), true);
      });
    });

    group('Subject Management', () {
      test('setSubject updates the subject', () {
        timerProvider.setSubject('Fisika');
        expect(timerProvider.subject, 'Fisika');
      });

      test('categories list is not empty', () {
        expect(timerProvider.categories.isNotEmpty, true);
        expect(timerProvider.categories.contains('Matematika'), true);
      });
    });

    group('Reset Functionality', () {
      test('resetAll returns to initial state', () {
        // Modify state
        timerProvider.setCustomFocusTime(45);
        timerProvider.startTimer();

        // Reset
        timerProvider.resetAll();

        expect(timerProvider.isRunning, false);
        expect(timerProvider.sessionType, SessionType.focus);
        expect(timerProvider.totalFocusElapsed, 0);
        expect(timerProvider.totalBreakElapsed, 0);
        expect(timerProvider.currentIteration, 1);
        expect(timerProvider.completedPomodoros, 0);
      });
    });
  });
}
