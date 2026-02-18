import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studysphere_app/shared/models/post_model.dart';
import 'package:studysphere_app/features/home/widgets/user_post_card.dart';

/// A minimal page that loads and shows a single post by its Firestore ID.
class PostDetailPage extends StatelessWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Post tidak ditemukan.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final post = PostModel.fromFirestore(snapshot.data!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: UserPostCard(post: post),
          );
        },
      ),
    );
  }
}
