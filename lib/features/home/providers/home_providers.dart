import 'package:flutter/material.dart';
import 'package:studysphere_app/features/home/pages/home_page.dart';

class HomeViewModel extends ChangeNotifier {
  int _currIdx = 0;
  late final ScrollController homeScrollController;
  final GlobalKey<MainPageState> mainPageKey = GlobalKey<MainPageState>();

  int get currIdx => _currIdx;

  HomeViewModel() {
    homeScrollController = ScrollController();
  }

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
      mainPageKey.currentState?.refreshFeed();
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
