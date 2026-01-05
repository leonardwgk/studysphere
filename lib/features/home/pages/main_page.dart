import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/auth/providers/user_provider.dart';
import 'package:studysphere_app/features/calender/providers/calendar_provider.dart';
import 'package:studysphere_app/features/home/providers/home_providers.dart';
import 'package:studysphere_app/features/home/widgets/header_section.dart';
import 'package:studysphere_app/features/home/widgets/post_feed_section.dart';
import 'package:studysphere_app/features/home/widgets/progress_calendar.dart';
import 'package:studysphere_app/features/home/widgets/start_study_button.dart';
import 'package:studysphere_app/features/home/widgets/stats_section.dart';

class MainPage extends StatefulWidget {
  final ScrollController? scrollController;
  final void Function(int) onNavigateToTab;
  const MainPage({
    super.key,
    this.scrollController,
    required this.onNavigateToTab,
  });

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  void _initData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    if (userProvider.user != null) {
      // Load stats from CalendarProvider (with caching)
      calendarProvider.loadHomeData(userProvider.user!.uid);
      // Load social feed posts
      homeProvider.fetchPosts();
    }
  }

  void refreshFeed() {
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    final calendarProvider = context.watch<CalendarProvider>();
    
    return SafeArea(
      // RefreshIndicator untuk fitur Pull-to-Refresh
      child: RefreshIndicator(
        onRefresh: () async {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          if (userProvider.user != null) {
            // Force refresh on pull-to-refresh
            await context.read<CalendarProvider>().forceRefresh(userProvider.user!.uid);
          }
        },
        child: SingleChildScrollView(
          // physics: AlwaysScrollableScrollPhysics wajib agar bisa di-pull meski konten sedikit
          physics: const AlwaysScrollableScrollPhysics(),
          controller: widget.scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const HeaderSection(),
                const SizedBox(height: 30),
                ProgressCalendar(
                  onViewCalendar: () => widget.onNavigateToTab(2),
                  weeklySummaries: calendarProvider.weeklySummaries,
                ),
                const SizedBox(height: 30),
                const StartStudyButton(),
                const SizedBox(height: 30),
                const StatsSection(),
                const SizedBox(height: 30),
                const PostFeedSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
