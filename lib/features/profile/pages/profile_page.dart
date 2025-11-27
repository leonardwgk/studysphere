import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Profile Header (Avatar & Info)
              // const ProfileHeader(),
              // const SizedBox(height: 20),

              // 2. Action Buttons (Edit, Share, Add)
              // const ActionButtons(),
              // const SizedBox(height: 30),

              // 3. Badges Section
              // const BadgesSection(),
              // const SizedBox(height: 30),

              // 4. Weekly Report (Chart)
              // const WeeklyReportSection(),
              // const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}



