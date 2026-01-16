// test/features/home/services/home_service_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studysphere_app/features/home/services/home_service.dart';

void main() {
  group('HomeService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late HomeService homeService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      homeService = HomeService(firestore: fakeFirestore);
    });

    group('getFeedPosts', () {
      test('returns empty list when no posts exist', () async {
        final posts = await homeService.getFeedPosts();
        expect(posts, isEmpty);
      });

      test('returns posts sorted by createdAt descending', () async {
        // Arrange: Add test posts to fake Firestore
        final now = DateTime.now();
        await fakeFirestore.collection('posts').add({
          'userId': 'user1',
          'username': 'Alice',
          'userPhotoUrl': '',
          'title': 'First Post',
          'description': 'Description 1',
          'label': 'Matematika',
          'imageUrl': '',
          'focusTime': 25,
          'breakTime': 5,
          'createdAt': Timestamp.fromDate(
            now.subtract(const Duration(hours: 2)),
          ),
        });
        await fakeFirestore.collection('posts').add({
          'userId': 'user2',
          'username': 'Bob',
          'userPhotoUrl': '',
          'title': 'Second Post',
          'description': 'Description 2',
          'label': 'Fisika',
          'imageUrl': '',
          'focusTime': 30,
          'breakTime': 10,
          'createdAt': Timestamp.fromDate(now),
        });

        // Act
        final posts = await homeService.getFeedPosts();

        // Assert
        expect(posts.length, 2);
        expect(posts[0].title, 'Second Post'); // Newer first
        expect(posts[1].title, 'First Post');
      });

      test('limits results to 10 posts', () async {
        // Arrange: Add 15 posts
        for (int i = 0; i < 15; i++) {
          await fakeFirestore.collection('posts').add({
            'userId': 'user$i',
            'username': 'User $i',
            'userPhotoUrl': '',
            'title': 'Post $i',
            'description': '',
            'label': 'Subject',
            'imageUrl': '',
            'focusTime': 25,
            'breakTime': 5,
            'createdAt': Timestamp.fromDate(DateTime.now()),
          });
        }

        // Act
        final posts = await homeService.getFeedPosts();

        // Assert: Should only return 10
        expect(posts.length, 10);
      });

      test('correctly maps Firestore data to PostModel', () async {
        // Arrange
        final testDate = DateTime(2026, 1, 15, 10, 30);
        await fakeFirestore.collection('posts').add({
          'userId': 'user123',
          'username': 'TestUser',
          'userPhotoUrl': 'https://example.com/photo.jpg',
          'title': 'My Study Session',
          'description': 'Learned calculus',
          'label': 'Matematika',
          'imageUrl': 'https://example.com/image.jpg',
          'focusTime': 45,
          'breakTime': 15,
          'createdAt': Timestamp.fromDate(testDate),
        });

        // Act
        final posts = await homeService.getFeedPosts();

        // Assert
        expect(posts.length, 1);
        final post = posts[0];
        expect(post.userId, 'user123');
        expect(post.username, 'TestUser');
        expect(post.userPhotoUrl, 'https://example.com/photo.jpg');
        expect(post.title, 'My Study Session');
        expect(post.description, 'Learned calculus');
        expect(post.label, 'Matematika');
        expect(post.imageUrl, 'https://example.com/image.jpg');
        expect(post.focusTime, 45);
        expect(post.breakTime, 15);
      });

      test('handles posts with missing optional fields', () async {
        // Arrange: Add a post with minimal data
        await fakeFirestore.collection('posts').add({
          'userId': 'user1',
          'username': 'User',
          'userPhotoUrl': '',
          'title': 'Minimal Post',
          'label': 'Subject',
          'focusTime': 25,
          'breakTime': 5,
          'createdAt': Timestamp.now(),
          // Intentionally missing: description, imageUrl
        });

        // Act
        final posts = await homeService.getFeedPosts();

        // Assert: Should still work with defaults
        expect(posts.length, 1);
        expect(posts[0].description, ''); // Default empty
      });
    });
  });
}
