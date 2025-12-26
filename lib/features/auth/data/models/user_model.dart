import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String photoUrl;
  final List<String> searchKeywords;
  final int totalFocusTime;
  final int totalBreakTime;
  final int followingCount;
  final int followersCount;
  final List<String> badges;
  final DateTime createdAt;

  UserModel({
    required this.uid, required this.email, required this.username,
    this.photoUrl = '', this.searchKeywords = const [],
    this.totalFocusTime = 0, this.totalBreakTime = 0,
    this.followingCount = 0, this.followersCount = 0,
    this.badges = const [], required this.createdAt,
  });

  // Untuk mengubah data dari Firestore (Map) ke Object Dart
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
      totalFocusTime: data['totalFocusTime'] ?? 0,
      totalBreakTime: data['totalBreakTime'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      followersCount: data['followersCount'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}