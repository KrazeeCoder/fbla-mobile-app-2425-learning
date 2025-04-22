import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_progress_model.dart';
import '../utils/app_logger.dart';

// This service is for interacting with user progress data in Firestore.
class ProgressService {
  // Firestore instance used for retrieving progress data.
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<UserProgress>> getHardcodedUserProgress() async {
    return [
      UserProgress(
        subject: 'Science',
        grade: 11,
        unit: 'Biology: Genetics and Human Systems',
        unitId: 1,
        subtopic: 'DNA Structure and Function',
        subtopicId: 'g11_bio_1',
        contentCompleted: false,
        quizCompleted: false,
        isCompleted: false,
        marksEarned: 5,
        lastAccessed: DateTime.now().subtract(Duration(hours: 12)),
        contentCompletedAt: DateTime.now().subtract(Duration(days: 1)),
        quizCompletedAt: null,
        startedAt: DateTime.now().subtract(Duration(days: 2)),
        lastActivityType: 'reading',
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Retrieves the most recent lesson progress entries for a user
  static Future<List<UserProgress>> fetchRecentLessons(String userId,
      {bool latest = false}) async {
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

      // Sort entries by lastAccessed in descending order
      progressList.sort((a, b) =>
          b.lastAccessed?.compareTo(a.lastAccessed ?? DateTime(0)) ?? 0);

      if (latest) {
        return progressList.isNotEmpty ? [progressList.first] : [];
      } else {
        return progressList.take(10).toList();
      }
    } catch (e, stacktrace) {
      AppLogger.e('Error fetching recent lessons',
          error: e, stackTrace: stacktrace);
      return [];
    }
  }

  /// Counts the total completed subtopics for a user
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

  // Calculates the user's level and total points based on XP
  static Future<Map<String, dynamic>> calculateLevelAndPoints(
      String uid) async {
    try {
      // Retrieve user's total XP from the 'users' collection
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};
      final int totalPoints = (userData['currentXP'] as num?)?.toInt() ?? 0;

      // Query 'level_master' to determine the appropriate level
      final levelQuery = await _firestore
          .collection('level_master')
          .where('minimum_point', isLessThanOrEqualTo: totalPoints)
          .where('maximum_point', isGreaterThanOrEqualTo: totalPoints)
          .limit(1)
          .get();

      int currentLevel = 1;
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

  // Retrieves all progress entries for a user.
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
