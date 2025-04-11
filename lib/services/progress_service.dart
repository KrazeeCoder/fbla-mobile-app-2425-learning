import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_progress_model.dart';
import '../utils/app_logger.dart';

class ProgressService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<UserProgress>> fetchRecentLessons(String userId) async {
    try {
      final snapshot =
          await _firestore.collection('user_progress').doc(userId).get();

      if (!snapshot.exists || snapshot.data() == null) {
        return [];
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final List<UserProgress> progressList = [];

      data.forEach((key, value) {
        try {
          progressList.add(UserProgress.fromMap(value));
        } catch (e) {
          AppLogger.e('Failed to parse progress entry [$key]', error: e);
        }
      });

      // Sort by lastAccessed descending
      progressList.sort((a, b) =>
          b.lastAccessed?.compareTo(a.lastAccessed ?? DateTime(0)) ?? 0);

      final top10 = progressList.take(10).toList();
      return top10;
    } catch (e, stacktrace) {
      AppLogger.e('Error fetching recent lessons',
          error: e, stackTrace: stacktrace);
      return [];
    }
  }

  // Returns total number of completed subtopics for a given user
  static Future<int> getTotalSubtopicsCompleted(String userId) async {
    try {
      final snapshot =
          await _firestore.collection('user_progress').doc(userId).get();

      final data = snapshot.data() ?? {};

      int completedCount = 0;

      for (final entry in data.entries) {
        final value = entry.value;
        if (value is Map && value['isCompleted'] == true) {
          completedCount++;
        }
      }

      return completedCount;
    } catch (e) {
      AppLogger.e('Error counting completed subtopics', error: e);
      return 0;
    }
  }

  static Future<Map<String, dynamic>> calculateLevelAndPoints(
      String uid) async {
    try {
      // Get user's currentXP directly from the users collection
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};
      final int totalPoints = (userData['currentXP'] as num?)?.toInt() ?? 0;

      // Find user level from level_master
      final levelQuery = await _firestore
          .collection('level_master')
          .where('minimum_point', isLessThanOrEqualTo: totalPoints)
          .where('maximum_point', isGreaterThanOrEqualTo: totalPoints)
          .limit(1)
          .get();

      int currentLevel = 1; // Default to level 1
      if (levelQuery.docs.isNotEmpty) {
        currentLevel = levelQuery.docs.first.data()['Level'] ?? 1;
      }

      return {
        'totalPoints': totalPoints,
        'currentLevel': currentLevel,
      };
    } catch (e) {
      AppLogger.e('Error calculating level and points', error: e);
      return {'totalPoints': 0, 'currentLevel': 1};
    }
  }

  // Calculate the user's streak based on their activity data
  static Future<int> getUserStreak(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};

      // Check if streak data exists in user document
      if (userData['streak'] != null && userData['lastActivityDate'] != null) {
        final int currentStreak = (userData['streak'] as num?)?.toInt() ?? 0;
        final Timestamp lastActivityDate =
            userData['lastActivityDate'] as Timestamp;
        final DateTime lastActivity = lastActivityDate.toDate();

        // Check if the last activity was today
        final DateTime today = DateTime.now();
        final bool isToday = lastActivity.year == today.year &&
            lastActivity.month == today.month &&
            lastActivity.day == today.day;

        // Check if the last activity was yesterday
        final DateTime yesterday = today.subtract(const Duration(days: 1));
        final bool isYesterday = lastActivity.year == yesterday.year &&
            lastActivity.month == yesterday.month &&
            lastActivity.day == yesterday.day;

        if (isToday) {
          // User already has activity today, return current streak
          return currentStreak;
        } else if (isYesterday) {
          // User had activity yesterday, streak is still valid
          return currentStreak;
        } else {
          // User missed a day, streak resets
          // We should update the streak in the database here, but for now just return 0
          return 0;
        }
      }

      // If no streak data exists, check recent activity from progress data
      final progressSnapshot =
          await _firestore.collection('user_progress').doc(userId).get();

      final progressData = progressSnapshot.data() ?? {};

      // Find the most recent activity
      DateTime? mostRecentActivity;

      for (final entry in progressData.entries) {
        final data = entry.value;
        if (data is Map && data['lastAccessed'] != null) {
          final Timestamp timestamp = data['lastAccessed'] as Timestamp;
          final DateTime activityDate = timestamp.toDate();

          if (mostRecentActivity == null ||
              activityDate.isAfter(mostRecentActivity)) {
            mostRecentActivity = activityDate;
          }
        }
      }

      if (mostRecentActivity != null) {
        // For now, return 1 if there's any recent activity, as we don't have historical data
        return 1;
      }

      return 0;
    } catch (e) {
      AppLogger.e('Error calculating user streak', error: e);
      return 0;
    }
  }

  // Fetch all user progress data
  static Future<Map<String, dynamic>> getUserProgress(String userId) async {
    try {
      final snapshot =
          await _firestore.collection('user_progress').doc(userId).get();

      return snapshot.data() ?? {};
    } catch (e) {
      AppLogger.e('Error fetching user progress', error: e);
      return {};
    }
  }
}
