import 'package:flutter/material.dart';
import 'package:studysphere_app/features/home/widgets/user_post_card.dart';

class PostFeedSection extends StatelessWidget {
  const PostFeedSection({super.key});

  // Data dummy nanti diganti ke StreamBuilder/FutureBuilder Firebase
  final List<Map<String, String>> dummyPosts = const [
    {
      'name': 'John Doe',
      'handle': '@jhonyyespapa',
      'caption': 'Gini ya rasanya kuliah',
      'imageUrl': 'https://picsum.photos/seed/study1/400/250',
      'duration': '1:20:21',
      'focusTime': '55:12',
      'breakTime': '25:09',
    },
    {
      'name': 'Jane Smith',
      'handle': '@janestudy',
      'caption': 'Hari ini target coding 4 jam tercapai!',
      'imageUrl': 'https://picsum.photos/seed/code2/400/250',
      'duration': '4:00:00',
      'focusTime': '3:30:00',
      'breakTime': '30:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Keep on track!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        // TEMPLATE FIREBASE: Ganti dengan StreamBuilder atau FutureBuilder nanti
        // Gunakan ListView.builder dengan properti untuk mengizinkan scrolling penuh
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dummyPosts.length,
          itemBuilder: (context, index) {
            final post = dummyPosts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: UserPostCard(
                name: post['name']!,
                handle: post['handle']!,
                caption: post['caption']!,
                imageUrl: post['imageUrl']!,
                duration: post['duration']!,
                focusTime: post['focusTime']!,
                breakTime: post['breakTime']!,
              ),
            );
          },
        ),
      ],
    );
  }
}
