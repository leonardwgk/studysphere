import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studysphere_app/shared/models/user_model.dart';
import 'package:studysphere_app/features/friend/services/friend_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendProvider extends ChangeNotifier {
  final FriendService _friendService = FriendService();

  // --- Search State ---
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  // --- Follow/Unfollow Logic State ---
  Set<String> _followingUids = {}; // List UID yang SAYA follow (untuk status tombol)
  final Set<String> _loadingFollowUids = {};

  // --- List Page State (Fitur Baru) ---
  List<UserModel> _followersList = []; // List orang yang mem-follow target
  List<UserModel> _followingList = []; // List orang yang di-follow target
  bool _isLoadingList = false;

  // Getters
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  
  List<UserModel> get followersList => _followersList;
  List<UserModel> get followingList => _followingList;
  bool get isLoadingList => _isLoadingList;

  // Constructor
  FriendProvider() {
    _loadMyFollowingData();
  }

  // 1. Load data siapa saja yang SAYA (Current User) follow
  // Ini penting agar tombol Follow/Unfollow di list tampil dengan benar statusnya
  Future<void> _loadMyFollowingData() async {
    try {
      _followingUids = await _friendService.getFollowingUids();
      notifyListeners();
    } catch (e) {
      print("Error loading my following data: $e");
    }
  }

  // 2. Load List Followers & Following milik user tertentu (Target User)
  Future<void> loadFollowLists(String targetUserId) async {
    _isLoadingList = true;
    _followersList = []; // Reset dulu biar bersih
    _followingList = [];
    notifyListeners();

    try {
      // Fetch kedua list secara parallel agar cepat
      final results = await Future.wait([
        _friendService.getFollowersList(targetUserId),
        _friendService.getFollowingList(targetUserId),
      ]);

      _followersList = results[0];
      _followingList = results[1];
      
      // Refresh juga data "My Following" untuk memastikan status tombol akurat
      await _loadMyFollowingData(); 

    } catch (e) {
      print("Error loading lists: $e");
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  // Cek apakah user sedang di-follow oleh SAYA
  bool isFollowing(String uid) {
    return _followingUids.contains(uid);
  }

  // --- Fungsi Search (Tetap sama) ---
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      _searchResults = [];
      _isLoading = false;
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

  // --- Toggle Follow Logic (Tetap sama, logic ini akan update UI otomatis) ---
  Future<void> toggleFollow(UserModel user) async {
    if (_loadingFollowUids.contains(user.uid)) return;

    _loadingFollowUids.add(user.uid);

    final isCurrentlyFollowing = isFollowing(user.uid);

    // Optimistic UI Update (Ubah tampilan dulu sebelum request selesai)
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
      // Rollback jika error
      if (isCurrentlyFollowing) {
        _followingUids.add(user.uid);
      } else {
        _followingUids.remove(user.uid);
      }
      notifyListeners();
      print("Toggle follow error: $e");
    } finally {
      _loadingFollowUids.remove(user.uid);
      notifyListeners(); // Ensure loading state is cleared
    }
  }

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