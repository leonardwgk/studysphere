import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studysphere_app/features/friend/providers/friend_provider.dart';
import 'package:studysphere_app/features/friend/pages/friend_profile_page.dart'; // Sesuaikan path ini
import 'package:studysphere_app/shared/models/user_model.dart';
import 'package:studysphere_app/shared/widgets/custom_avatar.dart'; // Sesuaikan path ini

class FollowListPage extends StatefulWidget {
  final String userId;       // ID pemilik profil yang sedang dilihat
  final String username;     // Nama pemilik profil
  final int initialIndex;    // 0 = Followers, 1 = Following

  const FollowListPage({
    super.key,
    required this.userId,
    required this.username,
    this.initialIndex = 0,
  });

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
    
    // Panggil provider untuk load data saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendProvider>().loadFollowLists(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username, style: const TextStyle(fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Following"),
            Tab(text: "Followers"),
          ],
        ),
      ),
      body: Consumer<FriendProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingList) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildUserList(provider.followingList, provider), // Tab 1
              _buildUserList(provider.followersList, provider), // Tab 2
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users, FriendProvider provider) {
    if (users.isEmpty) {
      return const Center(
        child: Text("Tidak ada pengguna.", style: TextStyle(color: Colors.grey)),
      );
    }

    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isMe = user.uid == currentUid;
        final isFollowing = provider.isFollowing(user.uid);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          
          // 1. Navigasi ke Profil saat diklik
          onTap: isMe ? null : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FriendProfilePage(userId: user.uid),
              ),
            );
          },

          // Avatar
          leading: CustomAvatar(photoUrl: user.photoUrl, name: user.username, radius: 24),
          
          // Nama & Email
          title: Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis),

          // 2. Tombol Follow/Unfollow
          trailing: isMe 
            ? null // Tidak ada tombol jika itu diri sendiri
            : SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: () async {
                    await provider.toggleFollow(user);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.grey[300] : Colors.blue,
                    foregroundColor: isFollowing ? Colors.black : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    isFollowing ? "Unfollow" : "Follow",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
        );
      },
    );
  }
}