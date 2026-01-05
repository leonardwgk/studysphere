import 'package:flutter/material.dart';
import 'package:studysphere_app/features/calender/services/calendar_service.dart';
import 'package:studysphere_app/features/home/data/models/summary_model.dart';

/// CalendarProvider with intelligent caching to minimize Firestore API calls.
///
/// Strategy:
/// 1. Load summaries by month (not all at once)
/// 2. Cache loaded months in memory
/// 3. Lazy-load session details only when user requests
/// 4. Share cache between Home and Calendar pages
class CalendarProvider extends ChangeNotifier {
  final CalendarService _calendarService = CalendarService();

  // Cache: Map<"YYYY-MM", Map<DateTime, SummaryModel>>
  final Map<String, Map<DateTime, SummaryModel>> _monthCache = {};

  // Cache for session details: Map<"YYYY-MM-DD", List<Session>>
  final Map<String, List<Map<String, dynamic>>> _sessionCache = {};

  // Current user ID
  String? _userId;

  // Loading states
  bool _isLoadingMonth = false;
  bool _isLoadingSessions = false;

  // Weekly summaries for ProgressCalendar (shared with Home)
  List<SummaryModel> _weeklySummaries = [];

  // Today's summary for stats
  SummaryModel? _todaySummary;

  // Getters
  bool get isLoadingMonth => _isLoadingMonth;
  bool get isLoadingSessions => _isLoadingSessions;
  bool get isLoading => _isLoadingMonth; // Alias for UI compatibility
  List<SummaryModel> get weeklySummaries => _weeklySummaries;
  SummaryModel? get todaySummary => _todaySummary;

  // Stats getters
  int get todayFocus => _todaySummary?.dailyFocus ?? 0;
  int get todayBreak => _todaySummary?.dailyBreak ?? 0;
  int get todayTotal => _todaySummary?.dailyTotal ?? 0;
  int get todayAll => todayTotal; // Alias for compatibility

  int get weeklyFocus {
    return _weeklySummaries.fold(0, (sum, s) => sum + s.dailyFocus);
  }

  int get weeklyBreak {
    return _weeklySummaries.fold(0, (sum, s) => sum + s.dailyBreak);
  }

  int get weeklyTotal => weeklyFocus + weeklyBreak;
  int get weeklyAll => weeklyTotal; // Alias for compatibility

  /// Set user ID (call on login)
  void setUserId(String userId) {
    if (_userId != userId) {
      _userId = userId;
      // Clear cache when user changes
      _monthCache.clear();
      _sessionCache.clear();
      _weeklySummaries = [];
      _todaySummary = null;
    }
  }

  /// Get month key for caching
  String _getMonthKey(int year, int month) {
    return '$year-${month.toString().padLeft(2, '0')}';
  }

  /// Get date key for session caching
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Load summaries for a specific month (with caching)
  /// Returns cached data if available, otherwise fetches from Firestore
  Future<Map<DateTime, SummaryModel>> getMonthSummaries(
    String userId,
    DateTime month,
  ) async {
    setUserId(userId);
    return _getMonthSummariesInternal(month.year, month.month);
  }

  /// Internal method for loading month summaries
  Future<Map<DateTime, SummaryModel>> _getMonthSummariesInternal(
    int year,
    int month,
  ) async {
    if (_userId == null) return {};

    final monthKey = _getMonthKey(year, month);

    // Check cache first
    if (_monthCache.containsKey(monthKey)) {
      debugPrint("📦 Cache HIT for $monthKey");
      return _monthCache[monthKey]!;
    }

    // Fetch from Firestore
    debugPrint("🔥 Fetching month $monthKey from Firestore");
    _isLoadingMonth = true;
    notifyListeners();

    try {
      final summaries = await _calendarService.getMonthlySummaries(
        _userId!,
        year,
        month,
      );

      // Store in cache
      _monthCache[monthKey] = summaries;

      return summaries;
    } catch (e) {
      debugPrint("Error loading month summaries: $e");
      return {};
    } finally {
      _isLoadingMonth = false;
      notifyListeners();
    }
  }

  /// Get summary for a specific day (from cache, no API call)
  SummaryModel? getSummaryForDay(DateTime day) {
    final monthKey = _getMonthKey(day.year, day.month);
    final monthData = _monthCache[monthKey];

    if (monthData == null) return null;

    return monthData[DateTime.utc(day.year, day.month, day.day)];
  }

  /// Check if a day has study data (from cache)
  bool hasStudyOnDay(DateTime day) {
    final summary = getSummaryForDay(day);
    return summary != null && summary.dailyTotal > 0;
  }

  /// Load sessions for a specific date (lazy load with caching)
  Future<List<Map<String, dynamic>>> getSessionsForDate(
    String userId,
    DateTime date,
  ) async {
    setUserId(userId);
    return _getSessionsForDateInternal(date);
  }

  /// Internal method for loading sessions
  Future<List<Map<String, dynamic>>> _getSessionsForDateInternal(
    DateTime date,
  ) async {
    if (_userId == null) return [];

    final dateKey = _getDateKey(date);

    // Check cache first
    if (_sessionCache.containsKey(dateKey)) {
      debugPrint("📦 Session cache HIT for $dateKey");
      return _sessionCache[dateKey]!;
    }

    // Fetch from Firestore
    debugPrint("🔥 Fetching sessions for $dateKey from Firestore");
    _isLoadingSessions = true;
    notifyListeners();

    try {
      final sessions = await _calendarService.getSessionsForDate(
        _userId!,
        date,
      );

      // Store in cache
      _sessionCache[dateKey] = sessions;

      return sessions;
    } catch (e) {
      debugPrint("Error loading sessions: $e");
      return [];
    } finally {
      _isLoadingSessions = false;
      notifyListeners();
    }
  }

  /// Load data for Home page (today + this week) AND current month for Calendar
  /// This is the main entry point - called once on login
  Future<void> loadHomeData(String userId) async {
    setUserId(userId);

    _isLoadingMonth = true;
    notifyListeners();

    debugPrint("🏠 Loading home data for user: $_userId");

    try {
      final now = DateTime.now();

      // 1. Load this week's summaries (for ProgressCalendar and weekly stats)
      _weeklySummaries = await _calendarService.getWeeklySummaries(_userId!);

      // 2. Get today's summary from the weekly data (no extra API call)
      final todayStr = _getDateKey(now);
      _todaySummary = _weeklySummaries.firstWhere(
        (s) => s.date == todayStr,
        orElse: () => SummaryModel(userId: _userId!, date: todayStr),
      );

      // 3. Also cache this week's data in month cache for calendar
      final monthKey = _getMonthKey(now.year, now.month);
      if (!_monthCache.containsKey(monthKey)) {
        _monthCache[monthKey] = {};
      }
      for (var summary in _weeklySummaries) {
        final parts = summary.date.split('-');
        if (parts.length == 3) {
          final date = DateTime.utc(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          _monthCache[monthKey]![date] = summary;
        }
      }

      // 4. Preload current month for Calendar page (so it's ready when user navigates)
      await _getMonthSummariesInternal(now.year, now.month);

      debugPrint(
        "✅ Home data loaded: ${_weeklySummaries.length} weekly summaries",
      );
    } catch (e) {
      debugPrint("Error loading home data: $e");
    } finally {
      _isLoadingMonth = false;
      notifyListeners();
    }
  }

  /// Force refresh all data (after posting a session)
  Future<void> forceRefresh(String userId) async {
    setUserId(userId);

    debugPrint("🔄 Force refreshing all calendar data");

    // Clear caches
    _monthCache.clear();
    _sessionCache.clear();

    // Reload home data
    await loadHomeData(_userId!);

    // Reload current month (in case calendar is open)
    final now = DateTime.now();
    await _getMonthSummariesInternal(now.year, now.month);
  }

  /// Invalidate cache for a specific date (after posting)
  void invalidateDate(DateTime date) {
    final dateKey = _getDateKey(date);
    _sessionCache.remove(dateKey);

    // Also remove from month cache to force re-fetch
    final monthKey = _getMonthKey(date.year, date.month);
    _monthCache.remove(monthKey);

    debugPrint("🗑️ Invalidated cache for $dateKey");
  }

  /// Preload adjacent months for smoother navigation
  Future<void> preloadAdjacentMonths(int year, int month) async {
    // Preload previous month
    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;
    _getMonthSummariesInternal(
      prevYear,
      prevMonth,
    ); // Don't await, fire and forget

    // Preload next month
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    _getMonthSummariesInternal(
      nextYear,
      nextMonth,
    ); // Don't await, fire and forget
  }
}
