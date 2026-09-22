import 'package:flutter/foundation.dart';

import 'package:lays_rating/models/user.dart';
import 'package:lays_rating/models/stats/stats_user.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/services/stats_service.dart';
import 'package:lays_rating/services/user_service.dart';

// Состояние и логика страницы своего профиля.
class ProfileController extends ChangeNotifier {
  ProfileController();

  User? _user;
  StatsUser? _stats;
  bool _isLoading = true;

  User? get user => _user;
  StatsUser? get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    await _loadUser();
    await _loadStats();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> reloadUser() async {
    await _loadUser();
    notifyListeners();
  }

  Future<void> reloadStats() async {
    await _loadStats();
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.logout();
    UserService.currentUser = null;
    _user = null;
    _stats = null;
    notifyListeners();
  }

  Future<void> _loadUser() async {
    try {
      final result = await UserService.getCurrentUser();
      _user = result;
    } catch (e) {
      debugPrint('ProfileController._loadUser error: $e');
    }
  }

  Future<void> _loadStats() async {
    final user = _user;
    if (user == null) return;

    try {
      _stats = await StatsService.getUserStats(user.id);
    } catch (e) {
      debugPrint('ProfileController._loadStats error: $e');
    }
  }
}