class PostModel {
  final String postId;
  final String userId;
  final String username; // Denormalized
  final String userPhotoUrl; // Denormalized
  final String title;
  final String description;
  final String label;
  final String imageUrl;
  final int focusTime;
  final DateTime createdAt;

  PostModel({
    required this.postId, required this.userId, required this.username,
    required this.userPhotoUrl, required this.title, this.description = '',
    required this.label, this.imageUrl = '', required this.focusTime,
    required this.createdAt,
  });

  // Tambahkan factory fromFirestore seperti UserModel...
}