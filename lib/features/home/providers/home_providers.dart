import 'package:flutter/material.dart';
import 'package:studysphere_app/shared/models/post_model.dart';
import 'package:studysphere_app/features/home/pages/main_page.dart';
import 'package:studysphere_app/features/home/services/home_service.dart';

/// HomeProvider handles UI state (navigation) and social feed only.
/// For stats & calendar data, use CalendarProvider instead.
class HomeProvider extends ChangeNotifier {
  // --- UI STATE (Navigation) ---
  int _currIdx = 0;
  late final ScrollController homeScrollController;
  final GlobalKey mainPageKey = GlobalKey();

  // --- DATA STATE (Social Feed) ---
  final HomeService _homeService = HomeService();
  List<PostModel> _posts = [];
  bool _isLoading = false;

  // Getters
  int get currIdx => _currIdx;
  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  HomeProvider() {
    homeScrollController = ScrollController();
    fetchPosts();
  }

  // --- SOCIAL FEED ---
  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await _homeService.getFeedPosts();
    } catch (e) {
      debugPrint("Error fetchPosts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- NAVIGATION ---
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
      // Refresh feed when tapping Home while already on Home
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
}
