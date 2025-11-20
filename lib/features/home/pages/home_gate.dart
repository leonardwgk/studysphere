import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/services/auth_service.dart';
import 'package:studysphere_app/features/calender/pages/calendar_page.dart';
import 'package:studysphere_app/features/friend/pages/friend_page.dart';
import 'package:studysphere_app/features/home/data/tabitems.dart';
import 'package:studysphere_app/features/home/pages/home_page.dart';
import 'package:studysphere_app/features/profile/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currIdx = 0;

  late final ScrollController _homeScrollController;
  final GlobalKey<MainPageState> _mainPageKey = GlobalKey<MainPageState>();

  late final List<Widget> _pages;

  void changeTab(int index) {
    setState(() {
      _currIdx = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _homeScrollController = ScrollController();

    // Inisialisasi _pages di sini agar bisa meneruskan controller & key
    _pages = [
      MainPage(
        key: _mainPageKey,
        scrollController: _homeScrollController,
        onNavigateToTab: changeTab,
      ),
      const FriendPage(),
      const CalendarPage(),
      const ProfilePage(),
    ];
  }

  @override
  void dispose() {
    _homeScrollController.dispose(); // Jangan lupa dispose controller
    super.dispose();
  }

  late final List<TabItem> _tabs = const [
    TabItem('Home', Icons.home),
    TabItem('Groups', Icons.people),
    TabItem('Calendar', Icons.calendar_month_outlined),
    TabItem('You', Icons.person_2_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    return Scaffold(
      appBar: _currIdx == 0
          ? null
          : AppBar(
              title: Text(_tabs[_currIdx].label),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await authService.signOut();
                  },
                ),
              ],
            ),

      body: IndexedStack(index: _currIdx, children: _pages),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currIdx,
        onTap: (idx) {
          if (idx == _currIdx && idx == 0) {
            _homeScrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
            _mainPageKey.currentState?.refreshFeed;
          } else {
            setState(() {
              _currIdx = idx;
            });
          }
        },
        items: List.generate(_tabs.length, (i) {
          final t = _tabs[i];
          final baseIcon = Icon(t.icon);
          return BottomNavigationBarItem(
            icon: i == 0
                ? Badge(child: baseIcon)
                : baseIcon, // keep Badge on first tab
            label: t.label,
          );
        }),
      ),
    );
  }
}
