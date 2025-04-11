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
