import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/calender/pages/calendar_page.dart';
import 'package:studysphere_app/features/friend/pages/friend_page.dart';
import 'package:studysphere_app/features/home/data/tabitems.dart';
import 'package:studysphere_app/features/home/pages/home_page.dart';
import 'package:studysphere_app/features/home/providers/home_view_model.dart';
import 'package:studysphere_app/features/profile/pages/profile_page.dart';
import 'package:studysphere_app/features/profile/widgets/app_bar.dart';
import 'package:studysphere_app/features/home/services/pending_session_service.dart';
import 'package:studysphere_app/features/home/pages/post_study_page.dart';

class HomeGate extends StatelessWidget {
  const HomeGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
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

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    _pages = [
      MainPage(
        key: viewModel.mainPageKey,
        scrollController: viewModel.homeScrollController,
        onNavigateToTab: viewModel.setIndex,
      ),
      const FriendPage(),
      const CalendarPage(),
      const ProfilePage(),
    ];

    _checkPendingSession();
  }

  Future<void> _checkPendingSession() async {
    final session = await PendingSessionService().getSession();
    if (session != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PostStudyPage(
            totalFocusTime: session['focusTime']!,
            totalBreakTime: session['breakTime']!,
          ),
        ),
      );
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
    final viewModel = Provider.of<HomeViewModel>(context);
    final currIdx = viewModel.currIdx;

    return Scaffold(
      appBar: _buildAppBar(currIdx),
      body: IndexedStack(index: currIdx, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currIdx,
        onTap: viewModel.onBottomNavTap,
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
