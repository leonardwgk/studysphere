// test/features/study_tracker/providers/timer_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:studysphere_app/features/study_tracker/providers/timer_provider.dart';

void main() {
  group('TimerProvider', () {
    late TimerProvider timerProvider;

    setUp(() {
      timerProvider = TimerProvider();
    });

    test('initial state is correct', () {
      expect(timerProvider.isRunning, false);
      expect(timerProvider.focusMinutes, 25);
      expect(timerProvider.shortBreakMinutes, 5);
    });

    test('startTimer sets isRunning to true', () {
      timerProvider.startTimer();
      expect(timerProvider.isRunning, true);
    });

    test('pauseTimer sets isRunning to false', () {
      timerProvider.startTimer();
      timerProvider.pauseTimer();
      expect(timerProvider.isRunning, false);
    });
  });
}