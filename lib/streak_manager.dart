import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages user's daily login streaks
class StreakManager extends ChangeNotifier {
  int _currentStreak = 0;
  DateTime? _lastLoginDate;
  bool _isLoading = true;

  StreakManager() {
    _loadStreakData();
  }

  /// Get the current streak
  int get currentStreak => _currentStreak;

  /// Get whether the streak data is still loading
  bool get isLoading => _isLoading;

  /// Load streak data from shared preferences
  Future<void> _loadStreakData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentStreak = prefs.getInt('streak_count') ?? 0;

      final lastLoginStr = prefs.getString('last_login_date');
      if (lastLoginStr != null) {
        _lastLoginDate = DateTime.parse(lastLoginStr);
      }

      // Update streak on new day login
      _updateStreak();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading streak data: $e');
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update streak based on last login date
  Future<void> _updateStreak() async {
    final today = DateTime.now();
    final lastLogin = _lastLoginDate;

    if (lastLogin == null) {
      // First login ever
      _currentStreak = 1;
      _lastLoginDate = today;
      await _saveStreakData();
      return;
    }

    // Check if logged in on different day
    final lastLoginDate =
        DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
    final todayDate = DateTime(today.year, today.month, today.day);

    if (todayDate.isAfter(lastLoginDate)) {
      final difference = todayDate.difference(lastLoginDate).inDays;

      if (difference == 1) {
        // Consecutive day login
        _currentStreak++;
      } else if (difference > 1) {
        // Streak broken
        _currentStreak = 1;
      }

      _lastLoginDate = today;
      await _saveStreakData();
    }
  }

  /// Save streak data to shared preferences
  Future<void> _saveStreakData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('streak_count', _currentStreak);
      await prefs.setString(
          'last_login_date', _lastLoginDate!.toIso8601String());
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving streak data: $e');
      }
    }
  }

  /// Reset streak (for testing purposes)
  Future<void> resetStreak() async {
    _currentStreak = 0;
    _lastLoginDate = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('streak_count');
      await prefs.remove('last_login_date');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting streak: $e');
      }
    }
  }
}
