import 'package:flutter/material.dart';
import 'package:studysphere_app/features/home/data/models/post_model.dart';
import 'package:studysphere_app/features/home/pages/main_page.dart';
import 'package:studysphere_app/features/study_tracker/services/study_service.dart';

class HomeProvider extends ChangeNotifier {
  // --- UI STATE (Navigasi) ---
  int _currIdx = 0;
  late final ScrollController homeScrollController;
  final GlobalKey mainPageKey = GlobalKey();

  // --- DATA STATE (Social Feed) ---
  final StudyService _studyService = StudyService();
  List<PostModel> _posts = [];
  bool _isLoading = false;
  DateTime? _lastFetchTime;

  // variables
  int _todayFocus = 0;
  int _todayBreak = 0;
  int _weeklyFocus = 0;
  int _weeklyBreak = 0;

  // Getters
  int get todayAll => _todayFocus + _todayBreak;
  int get weeklyAll => _weeklyFocus + _weeklyBreak;
  int get todayFocus => _todayFocus;
  int get todayBreak => _todayBreak;
  int get weeklyFocus => _weeklyFocus;
  int get weeklyBreak => _weeklyBreak;

  // Getters
  int get currIdx => _currIdx;
  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  HomeProvider() {
    homeScrollController = ScrollController();
    // Panggil fetchPosts saat aplikasi pertama kali jalan
    fetchPosts();
  }

  // --- LOGIKA DATA ---
  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await _studyService.getFeedPosts();
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- LOGIKA UI (Navigasi) ---
  void setIndex(int index) {
    _currIdx = index;
    notifyListeners();
  }

  void onBottomNavTap(int index) {
    if (index == _currIdx && index == 0) {
      homeScrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      // Panggil refreshFeed dari MainPage melalui GlobalKey
      (mainPageKey.currentState as MainPageState?)?.refreshFeed();
    } else {
      _currIdx = index;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    homeScrollController.dispose();
    super.dispose();
  }

  Future<void> fetchUserStats(String userId) async {
    print("DEBUG: Fetching stats for user: $userId");
    final now = DateTime.now();

    // 1. Tentukan Awal Hari (Jam 00:00:00 hari ini)
    final startOfDay = DateTime(now.year, now.month, now.day);

    // 2. Tentukan Awal Minggu (Senin jam 00:00:00)
    // now.weekday: Senin=1, Minggu=7
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));

    // Ambil data dari Service
    final todayData = await _studyService.getUserStats(
      userId: userId,
      startDate: startOfDay,
    );
    final weeklyData = await _studyService.getUserStats(
      userId: userId,
      startDate: startOfWeek,
    );

    _todayFocus = todayData['focus']!;
    _todayBreak = todayData['break']!;
    _weeklyFocus = weeklyData['focus']!;
    _weeklyBreak = weeklyData['break']!;

    notifyListeners();
  }

  // --- REFRESH SEMUA DATA SEKALIGUS ---
  Future<void> refreshAllData(String userId) async {
    // Jika sudah pernah fetch dalam 5 menit terakhir, batalkan fetch baru
    if (_lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 5) {
      debugPrint("Rate Limit: Menggunakan data yang sudah ada (Cache).");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([_fetchPostsInternal(), _fetchStatsInternal(userId)]);

      _lastFetchTime = DateTime.now(); // Catat waktu fetch terakhir yang sukses
    } catch (e) {
      // ...
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pindahkan logika fetchPosts ke fungsi internal tanpa notifyListeners sendiri
  Future<void> _fetchPostsInternal() async {
    _posts = await _studyService.getFeedPosts();
  }

  Future<void> _fetchStatsInternal(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));

    final results = await Future.wait([
      _studyService.getUserStats(userId: userId, startDate: startOfDay),
      _studyService.getUserStats(userId: userId, startDate: startOfWeek),
    ]);

    final todayData = results[0];
    final weeklyData = results[1];

    _todayFocus = todayData['focus']!;
    _todayBreak = todayData['break']!;
    _weeklyFocus = weeklyData['focus']!;
    _weeklyBreak = weeklyData['break']!;
  }
}
