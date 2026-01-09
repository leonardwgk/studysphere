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
    required this.uid,
    required this.email,
    required this.username,
    this.photoUrl = '',
    this.searchKeywords = const [],
    this.totalFocusTime = 0,
    this.totalBreakTime = 0,
    this.followingCount = 0,
    this.followersCount = 0,
    this.badges = const [],
    required this.createdAt,
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

  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserModel(
      uid: id ?? map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      searchKeywords: List<String>.from(map['searchKeywords'] ?? []),
      totalFocusTime: map['totalFocusTime'] ?? 0,
      totalBreakTime: map['totalBreakTime'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      followersCount: map['followersCount'] ?? 0,
      badges: List<String>.from(map['badges'] ?? []),
      
      // Mengambil createdAt dan mengubahnya dari Timestamp ke DateTime
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
