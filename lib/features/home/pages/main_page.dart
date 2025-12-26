import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/auth/providers/user_provider.dart';
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
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    if (userProvider.user != null) {
      homeProvider.refreshAllData(userProvider.user!.uid);
    }
  }

  void refreshFeed() {
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // RefreshIndicator untuk fitur Pull-to-Refresh
      child: RefreshIndicator(
        onRefresh: () async {
          _initData();
          // Beri sedikit delay agar animasinya terlihat natural
          await Future.delayed(const Duration(seconds: 1));
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
