import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/home/providers/home_providers.dart';
import 'package:studysphere_app/features/home/widgets/user_post_card.dart';

class PostFeedSection extends StatelessWidget {
  const PostFeedSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendengarkan perubahan data di HomeProvider
    final homeProvider = context.watch<HomeProvider>();

    if (homeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (homeProvider.posts.isEmpty) {
      return const Center(child: Text("Belum ada postingan belajar hari ini."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keep on track!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: homeProvider.posts.length,
          itemBuilder: (context, index) {
            final post = homeProvider.posts[index];
            return Padding(
              // Padding ini sekarang bertindak sebagai margin antar kartu
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: UserPostCard(post: post),
            );
          },
        ),
      ],
    );
  }
}
