import 'package:flutter/material.dart';
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
  void refreshFeed() {
    // TODO: Tambahkan logika untuk mengambil data baru dari Firebase di sini.
    debugPrint("Refreshing feed data...");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. Header (Halo [name] & Icon Notifikasi)
              const HeaderSection(),

              const SizedBox(height: 30),

              // 2. Your Progress (Kalender Hari)
              ProgressCalendar(
                onViewCalendar: () => widget.onNavigateToTab(2)
              ),

              const SizedBox(height: 30),

              // 3. Tombol Start Study
              const StartStudyButton(),

              const SizedBox(height: 30),

              // 4. Statistik Waktu Belajar (Today's & Weekly)
              const StatsSection(),

              const SizedBox(height: 30),

              // 5. Post Feed Section
              const PostFeedSection(),

              // Memberi jarak dari Bottom Navigation Bar
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
