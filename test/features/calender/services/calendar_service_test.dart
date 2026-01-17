// test/features/calender/services/calendar_service_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studysphere_app/features/calender/services/calendar_service.dart';
import 'package:studysphere_app/shared/models/summary_model.dart';

void main() {
  group('CalendarService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CalendarService calendarService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      calendarService = CalendarService(firestore: fakeFirestore);
    });

    group('getTodaySummary', () {
      test('returns null when no summary exists', () async {
        final result = await calendarService.getTodaySummary('user123');
        expect(result, isNull);
      });

      test('returns SummaryModel when summary exists', () async {
        // Arrange: Create summary for today
        final now = DateTime.now();
        final dateStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final docId = 'user123_$dateStr';

        await fakeFirestore.collection('daily_summaries').doc(docId).set({
          'userId': 'user123',
          'date': dateStr,
          'dailyFocus': 120,
          'dailyBreak': 30,
          'dailyTotal': 150,
          'labelsStudied': ['Matematika', 'Fisika'],
        });

        // Act
        final result = await calendarService.getTodaySummary('user123');

        // Assert
        expect(result, isNotNull);
        expect(result!.userId, 'user123');
        expect(result.dailyFocus, 120);
        expect(result.dailyBreak, 30);
        expect(result.dailyTotal, 150);
        expect(result.labelsStudied, contains('Matematika'));
      });
    });

    group('getWeeklySummaries', () {
      test('returns empty list when no summaries exist', () async {
        final result = await calendarService.getWeeklySummaries('user123');
        expect(result, isEmpty);
      });

      test('returns summaries for current week only', () async {
        // Arrange: Add summaries for this week and last week
        final now = DateTime.now();
        final monday = now.subtract(Duration(days: now.weekday - 1));

        // This week's summary
        final thisWeekDate =
            '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
        await fakeFirestore
            .collection('daily_summaries')
            .doc('user123_$thisWeekDate')
            .set({
              'userId': 'user123',
              'date': thisWeekDate,
              'dailyFocus': 60,
              'dailyBreak': 15,
              'dailyTotal': 75,
              'labelsStudied': ['Matematika'],
            });

        // Last week's summary (should NOT be returned)
        final lastWeek = monday.subtract(const Duration(days: 7));
        final lastWeekDate =
            '${lastWeek.year}-${lastWeek.month.toString().padLeft(2, '0')}-${lastWeek.day.toString().padLeft(2, '0')}';
        await fakeFirestore
            .collection('daily_summaries')
            .doc('user123_$lastWeekDate')
            .set({
              'userId': 'user123',
              'date': lastWeekDate,
              'dailyFocus': 90,
              'dailyBreak': 20,
              'dailyTotal': 110,
              'labelsStudied': ['Fisika'],
            });

        // Act
        final result = await calendarService.getWeeklySummaries('user123');

        // Assert: Should only return this week
        expect(result.length, 1);
        expect(result[0].dailyFocus, 60);
      });
    });

    group('getSessionsForDate', () {
      test('returns empty list when no sessions exist', () async {
        final result = await calendarService.getSessionsForDate(
          'user123',
          DateTime.now(),
        );
        expect(result, isEmpty);
      });

      test('returns sessions for specific date only', () async {
        // Arrange: Add posts for today and yesterday
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));

        // Today's post
        await fakeFirestore.collection('posts').add({
          'userId': 'user123',
          'title': 'Today Session',
          'focusTime': 25,
          'breakTime': 5,
          'label': 'Matematika',
          'description': 'Studied today',
          'createdAt': Timestamp.fromDate(today),
        });

        // Yesterday's post (should NOT be returned)
        await fakeFirestore.collection('posts').add({
          'userId': 'user123',
          'title': 'Yesterday Session',
          'focusTime': 30,
          'breakTime': 10,
          'label': 'Fisika',
          'description': 'Studied yesterday',
          'createdAt': Timestamp.fromDate(yesterday),
        });

        // Act
        final result = await calendarService.getSessionsForDate(
          'user123',
          today,
        );

        // Assert
        expect(result.length, 1);
        expect(result[0]['title'], 'Today Session');
        expect(result[0]['focusDuration'], 25);
        expect(result[0]['breakDuration'], 5);
      });

      test('correctly maps post fields to session format', () async {
        // Arrange
        final testDate = DateTime(2026, 1, 15, 14, 30);
        await fakeFirestore.collection('posts').add({
          'userId': 'user123',
          'title': 'Calculus Study',
          'focusTime': 45,
          'breakTime': 15,
          'label': 'Matematika',
          'description': 'Learned derivatives',
          'imageUrl': 'https://example.com/img.jpg',
          'username': 'TestUser',
          'userPhotoUrl': 'https://example.com/avatar.jpg',
          'createdAt': Timestamp.fromDate(testDate),
        });

        // Act
        final result = await calendarService.getSessionsForDate(
          'user123',
          testDate,
        );

        // Assert
        expect(result.length, 1);
        final session = result[0];
        expect(session['title'], 'Calculus Study');
        expect(session['focusDuration'], 45);
        expect(session['breakDuration'], 15);
        expect(session['totalDuration'], 60);
        expect(session['label'], 'Matematika');
        expect(session['description'], 'Learned derivatives');
        expect(session['imageUrl'], 'https://example.com/img.jpg');
        expect(session['username'], 'TestUser');
      });
    });

    group('calculateWeeklyTotals', () {
      test('returns zeros for empty list', () {
        final result = calendarService.calculateWeeklyTotals([]);
        expect(result['focus'], 0);
        expect(result['break'], 0);
        expect(result['total'], 0);
      });

      test('correctly sums multiple summaries', () {
        // Arrange: Create SummaryModel instances
        final summaries = [
          SummaryModel.fromMap({
            'userId': 'u1',
            'date': '2026-01-13',
            'dailyFocus': 60,
            'dailyBreak': 10,
            'dailyTotal': 70,
            'labelsStudied': <String>[],
          }),
          SummaryModel.fromMap({
            'userId': 'u1',
            'date': '2026-01-14',
            'dailyFocus': 45,
            'dailyBreak': 15,
            'dailyTotal': 60,
            'labelsStudied': <String>[],
          }),
          SummaryModel.fromMap({
            'userId': 'u1',
            'date': '2026-01-15',
            'dailyFocus': 90,
            'dailyBreak': 20,
            'dailyTotal': 110,
            'labelsStudied': <String>[],
          }),
        ];

        // Act
        final result = calendarService.calculateWeeklyTotals(summaries);

        // Assert
        expect(result['focus'], 195); // 60 + 45 + 90
        expect(result['break'], 45); // 10 + 15 + 20
        expect(result['total'], 240); // 195 + 45
      });
    });
  });
}
