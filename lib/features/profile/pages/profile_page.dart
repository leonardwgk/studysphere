// lib/features/profile/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:studysphere_app/shared/models/user_model.dart';
import 'package:studysphere_app/features/profile/services/profile_service.dart'; // Import Service
import 'package:studysphere_app/features/profile/widgets/action_buttons.dart';
import 'package:studysphere_app/features/profile/widgets/profile_header.dart';
import 'package:studysphere_app/features/profile/widgets/weekly_report_section.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Panggil service
    final ProfileService profileService = ProfileService();

    return SafeArea(
      child: StreamBuilder<UserModel>(
        stream: profileService.getUserStream(), // 1. Dengarkan data user
        builder: (context, snapshot) {
          // A. Jika sedang loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // B. Jika ada error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // C. Jika data berhasil didapat
          if (snapshot.hasData) {
            final UserModel currentUser = snapshot.data!;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kirim data user ke Header
                    ProfileHeader(user: currentUser),
                    const SizedBox(height: 20),

                    // Share dan Edit
                    ActionButtons(user: currentUser),
                    const SizedBox(height: 30),

                    // Nanti BadgesSection
                    // const BadgesSection(),
                    // const SizedBox(height: 30),

                    // Weekly Report
                    const WeeklyReportSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text("No Data Available"));
        },
      ),
    );
  }
}
