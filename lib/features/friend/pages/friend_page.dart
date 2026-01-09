import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/friend/providers/friend_provider.dart';
import 'package:studysphere_app/shared/widgets/custom_avatar.dart'; // Import CustomAvatar Anda

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Akses provider
    final friendProvider = Provider.of<FriendProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Find Friends',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          // --- 1. SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                // Panggil fungsi search di provider setiap user mengetik
                friendProvider.onSearchChanged(value);
              },
              decoration: InputDecoration(
                hintText: 'Search username...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          friendProvider.onSearchChanged(''); // Clear hasil
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- 2. SEARCH RESULT LIST ---
          Expanded(
            child: friendProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : friendProvider.searchResults.isEmpty && _searchController.text.isNotEmpty
                    ? _buildEmptyState() // State jika tidak ketemu
                    : _buildUserList(friendProvider), // State List User
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(FriendProvider provider) {
    if (provider.searchResults.isEmpty) {
      // Tampilan awal (sebelum search)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              "Search for study partners!",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.searchResults.length,
      itemBuilder: (context, index) {
        final user = provider.searchResults[index];
        return ListTile(
          leading: CustomAvatar(
            photoUrl: user.photoUrl,
            name: user.username,
            radius: 24, // Sedikit lebih besar
          ),
          title: Text(
            user.username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: ElevatedButton(
            onPressed: () {
              // TODO: Implementasi logika Follow nanti
              print("Follow ${user.username}");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              minimumSize: const Size(0, 32), // Tinggi tombol compact
            ),
            child: const Text('Follow', style: TextStyle(fontSize: 12)),
          ),
          onTap: () {
            // TODO: Navigasi ke Profile Teman
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "User not found.",
        style: TextStyle(color: Colors.grey[500]),
      ),
    );
  }
}