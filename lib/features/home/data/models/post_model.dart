import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final String title;
  final String description;
  final String label;
  final String imageUrl;
  final int focusTime;
  final int breakTime;
  final DateTime createdAt;

  PostModel({
    required this.postId,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.title,
    this.description = '',
    required this.label,
    this.imageUrl = '',
    required this.focusTime,
    required this.breakTime,
    required this.createdAt,
  });

  // Read from firestore
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return PostModel(
      postId: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      label: data['label'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      focusTime: data['focusTime'] ?? 0,
      breakTime: data['breakTime'] ?? 0,
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now()
    );
  }

  // used for write to firestore
  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "username": username,
      "userPhotoUrl": userPhotoUrl,
      "title": title,
      "description": description,
      "label": label,
      "imageUrl": imageUrl,
      "focusTime": focusTime,
      "breakTime": breakTime,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }
}