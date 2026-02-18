import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/auth/providers/user_provider.dart';
import 'package:studysphere_app/features/calender/pages/calendar_page.dart';
import 'package:studysphere_app/features/calender/providers/calendar_provider.dart';
import 'package:studysphere_app/features/friend/pages/friend_page.dart';
import 'package:studysphere_app/features/home/data/tabitems.dart';
import 'package:studysphere_app/features/home/pages/main_page.dart';
import 'package:studysphere_app/features/home/providers/home_providers.dart';
import 'package:studysphere_app/features/profile/pages/profile_page.dart';
import 'package:studysphere_app/features/profile/widgets/app_bar.dart';
import 'package:studysphere_app/features/study_tracker/services/notification_service.dart';

class HomeGate extends StatelessWidget {
  const HomeGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: const _HomeGateContent(),
    );
  }
}

class _HomeGateContent extends StatefulWidget {
  const _HomeGateContent();

  @override
  State<_HomeGateContent> createState() => _HomeGateContentState();
}

class _HomeGateContentState extends State<_HomeGateContent> {
  late final List<Widget> _pages;

  // Hapus import PendingSessionService yang lama
  // Hapus fungsi _checkPendingSession() di dalam State

  @override
  void initState() {
    super.initState();
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    _pages = [
      MainPage(
        key: homeProvider.mainPageKey,
        scrollController: homeProvider.homeScrollController,
        onNavigateToTab: homeProvider.setIndex,
      ),
      const FriendPage(),
      const CalendarPage(),
      const ProfilePage(),
    ];

    // Request notification permission when user first enters the app.
    // This shows the OS permission dialog on Android 13+.
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    try {
      final notificationService = NotificationService();
      await notificationService.requestPermission();
    } catch (e) {
      debugPrint('Failed to request notification permission: $e');
    }
  }

  void _handleBottomNavTap(BuildContext context, int index) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.onBottomNavTap(index);

    // Auto-reload calendar data each time user taps the Calendar tab
    if (index == 2) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final calendarProvider = Provider.of<CalendarProvider>(
        context,
        listen: false,
      );
      if (userProvider.user != null) {
        // softRefresh: keeps existing data on screen while re-fetching in background
        calendarProvider.softRefresh(userProvider.user!.uid);
      }
    }
  }

  final List<TabItem> _tabs = const [
    TabItem('Home', Icons.home),
    TabItem('Groups', Icons.people),
    TabItem('Calendar', Icons.calendar_month_outlined),
    TabItem('You', Icons.person_2_outlined),
  ];

  PreferredSizeWidget? _buildAppBar(int currIdx) {
    if (currIdx == 3) {
      return PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ProfileAppBar(),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final currIdx = homeProvider.currIdx;

    return Scaffold(
      appBar: _buildAppBar(currIdx),
      // IndexedStack make the body still alive in memory while navigating between pages.
      body: IndexedStack(index: currIdx, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currIdx,
        onTap: (index) => _handleBottomNavTap(context, index),
        items: List.generate(_tabs.length, (i) {
          final t = _tabs[i];
          final baseIcon = Icon(t.icon);
          return BottomNavigationBarItem(
            icon: i == 0 ? Badge(child: baseIcon) : baseIcon,
            label: t.label,
          );
        }),
      ),
    );
  }
}
