// lib/features/friend/pages/friend_profile_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:studysphere_app/features/auth/data/models/user_model.dart';
import 'package:studysphere_app/features/friend/providers/friend_provider.dart';
import 'package:studysphere_app/features/friend/services/friend_profile_service.dart';
import 'package:studysphere_app/features/profile/widgets/profile_header.dart';
import 'package:studysphere_app/features/profile/widgets/weekly_report_section.dart';

class FriendProfilePage extends StatelessWidget {
  final String userId;

  const FriendProfilePage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // Panggil service
    final FriendProfileService friendProfileService = FriendProfileService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<UserModel>(
          stream: friendProfileService.getFriendUserStream(userId),
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
              final UserModel friendUser = snapshot.data!;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER (reuse ProfileHeader)
                      ProfileHeader(user: friendUser),
                      const SizedBox(height: 20),

                      // FOLLOW / UNFOLLOW BUTTON
                      Consumer<FriendProvider>(
                        builder: (context, provider, _) {
                          final isFollowing = provider.isFollowing(friendUser.uid);

                          return SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () {
                                provider.toggleFollow(friendUser);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFollowing
                                    ? Colors.grey[300]
                                    : Colors.blue,
                                foregroundColor: isFollowing
                                    ? Colors.black
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                isFollowing ? 'Unfollow' : 'Follow',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // Weekly Report (sama seperti ProfilePage)
                      const WeeklyReportSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: Text("User not found"));
          },
        ),
      ),
    );
  }
}