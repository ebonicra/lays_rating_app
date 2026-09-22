import 'package:flutter/foundation.dart';

import 'package:lays_rating/models/user.dart';
import 'package:lays_rating/models/stats/stats_user.dart';
import 'package:lays_rating/services/follow_service.dart';
import 'package:lays_rating/services/stats_service.dart';
import 'package:lays_rating/services/user_service.dart';

// Состояние и логика страницы чужого профиля.
class PublicProfileController extends ChangeNotifier {
  PublicProfileController({required this.userId});

  final int userId;

  User? _user;
  StatsUser? _stats;
  bool _isLoading = true;

  bool? _isFollowing;
  bool _isFollowLoading = false;
  bool _isFollowingMe = false;

  User? get user => _user;
  StatsUser? get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isFollowing => _isFollowing == true;
  bool get isFollowLoading => _isFollowLoading;
  bool get isFollowingMe => _isFollowingMe;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await UserService.getUserById(userId);
      _stats = await StatsService.getUserStats(userId);

      final followStatus = await FollowService.checkFollowing(userId);
      _isFollowing = followStatus.isFollowing;

      await _checkIfFollowingMe();
    } catch (e) {
      debugPrint('PublicProfileController.load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFollow() async {
    if (_isFollowLoading) return;

    _isFollowLoading = true;
    notifyListeners();

    try {
      if (_isFollowing == true) {
        await FollowService.unfollowUser(userId);
        _isFollowing = false;
      } else {
        await FollowService.followUser(userId);
        _isFollowing = true;
      }

      // Обновляем статистику, чтобы счётчики подписчиков совпадали
      _stats = await StatsService.getUserStats(userId);
    } catch (e) {
      debugPrint('PublicProfileController.toggleFollow error: $e');
      rethrow;
    } finally {
      _isFollowLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkIfFollowingMe() async {
    final myUser = UserService.currentUser;
    if (myUser == null) return;

    try {
      final theirFollowing = await FollowService.getFollowing(userId: userId);
      _isFollowingMe = theirFollowing.any((u) => u.id == myUser.id);
    } catch (e) {
      debugPrint('PublicProfileController._checkIfFollowingMe error: $e');
    }
  }
}