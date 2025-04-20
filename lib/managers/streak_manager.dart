import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/progress_service.dart';
import '../utils/app_logger.dart';
import 'dart:math' as math;

class StreakManager {
  // Get the current streak for a user
  static Future<int> getCurrentStreak(String userId) async {
    try {
      return await _calculateStreakFromProgress(userId);
    } catch (e) {
      AppLogger.e('Error getting current streak', error: e);
      return 0;
    }
  }

  // Check if a user has maintained their streak today
  static Future<bool> hasMaintainedStreakToday(String userId) async {
    try {
      final progressData = await ProgressService.getUserProgress(userId);
      final today = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(today);

      for (final entry in progressData.entries) {
        final data = entry.value;
        if (data is Map && data['lastAccessed'] != null) {
          final Timestamp timestamp = data['lastAccessed'] as Timestamp;
          final DateTime activityDate = timestamp.toDate();
          final activityDateStr = DateFormat('yyyy-MM-dd').format(activityDate);

          if (activityDateStr == todayStr) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      AppLogger.e('Error checking streak maintenance', error: e);
      return false;
    }
  }

  // Private helper methods

  static Future<int> _calculateStreakFromProgress(String userId) async {
    try {
      final progressData = await ProgressService.getUserProgress(userId);
      final today = DateTime.now();
      var streak = 0;
      var currentDate = today;

      // Sort activities by date
      final activities = <DateTime>[];
      for (final entry in progressData.entries) {
        final data = entry.value;
        if (data is Map && data['lastAccessed'] != null) {
          final Timestamp timestamp = data['lastAccessed'] as Timestamp;
          activities.add(timestamp.toDate());
        }
      }
      activities.sort((a, b) => b.compareTo(a));

      // Calculate streak
      for (final activity in activities) {
        final activityDate = DateTime(
          activity.year,
          activity.month,
          activity.day,
        );
        final expectedDate = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );

        if (activityDate.isAtSameMomentAs(expectedDate) ||
            activityDate.isAtSameMomentAs(
              expectedDate.subtract(const Duration(days: 1)),
            )) {
          streak++;
          currentDate = activityDate;
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      AppLogger.e('Error calculating streak from progress', error: e);
      return 0;
    }
  }
}
