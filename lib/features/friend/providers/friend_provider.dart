import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/data/models/user_model.dart';
import 'package:studysphere_app/features/friend/services/friend_service.dart';

class FriendProvider extends ChangeNotifier {
  final FriendService _friendService = FriendService();

  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  Set<String> _followingUids = {};
  final Set<String> _loadingFollowUids = {};
  bool _isFollowingDataLoaded = false;

  // Getters
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  // Constructor
  FriendProvider() {
    _loadFollowingData();
  }

  // Muat data following dari service
  Future<void> _loadFollowingData() async {
    try {
      _followingUids = await _friendService.getFollowingUids();
      _isFollowingDataLoaded = true;
      notifyListeners();
    } catch (e) {
      print("Error loading following data: $e");
    }
  }

  // Refresh following data (dipanggil manual jika perlu)
  Future<void> refreshFollowingData() async {
    await _loadFollowingData();
  }

  // Cek apakah user sedang di-follow
  bool isFollowing(String uid) {
    return _followingUids.contains(uid);
  }

  // Fungsi Search dengan Debounce
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await _friendService.searchUsers(query);
      _searchResults = results;
    } catch (e) {
      print("Provider Error: $e");
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle Follow/Unfollow
  Future<void> toggleFollow(UserModel user) async {
    // Cegah klik spam
    if (_loadingFollowUids.contains(user.uid)) return;

    _loadingFollowUids.add(user.uid);

    final isCurrentlyFollowing = isFollowing(user.uid);

    if (isCurrentlyFollowing) {
      _followingUids.remove(user.uid);
    } else {
      _followingUids.add(user.uid);
    }
    notifyListeners();

    try {
      if (isCurrentlyFollowing) {
        await _friendService.unfollowUser(user.uid);
      } else {
        await _friendService.followUser(user.uid);
      }
      
    } catch (e) {
      if (isCurrentlyFollowing) {
        _followingUids.add(user.uid);
      } else {
        _followingUids.remove(user.uid);
      }
      notifyListeners();
      print("Toggle follow error: $e");
      
      // Tampilkan error ke user
      debugPrint("Failed to ${isCurrentlyFollowing ? 'unfollow' : 'follow'} user: $e");
    } finally {
      _loadingFollowUids.remove(user.uid);
    }
  }

  // Membersihkan hasil saat keluar halaman
  void clearSearch() {
    _searchResults = [];
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}