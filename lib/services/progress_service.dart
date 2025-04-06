import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_progress_model.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ProgressService {
  static Future<List<UserProgress>> fetchRecentLessons(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_progress')
          .doc(userId)
          .get();

      if (!snapshot.exists || snapshot.data() == null) {
        print('No progress data found for user: $userId');
        return [];
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final List<UserProgress> progressList = [];

      data.forEach((key, value) {
        try {
          progressList.add(UserProgress.fromMap(value));
        } catch (e) {
          print('Failed to parse progress entry [$key]: $e');
        }
      });

      // Sort by lastAccessed descending
      progressList.sort((a, b) =>
          b.lastAccessed?.compareTo(a.lastAccessed ?? DateTime(0)) ?? 0);

      final top10 = progressList.take(10).toList();
      print('✅ Top 10 Sorted Progress List: $top10');
      return top10;
    } catch (e, stacktrace) {
      print('❌ Error fetching recent lessons for user $userId: $e');
      print(stacktrace);
      return [];
    }
  }
}

// Returns total number of completed subtopics for a given user
Future<int> getTotalSubtopicsCompleted(String userId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('user_progress')
      .doc(userId)
      .get();

  final data = snapshot.data() ?? {};

  int completedCount = 0;

  for (final entry in data.entries) {
    final value = entry.value;
    if (value is Map && value['isCompleted'] == true) {
      completedCount++;
    }
  }

  return completedCount;
}

Future<Map<String, dynamic>> calculateLevelAndPoints(String uid) async {
  final firestore = FirebaseFirestore.instance;

  // Step 1: Get user_progress data
  final userProgressSnapshot =
      await firestore.collection('user_progress').doc(uid).get();
  final userProgress = userProgressSnapshot.data() ?? {};
  int totalPoints = 0;

  // Step 2: Add points from completed subtopics
  for (var entry in userProgress.entries) {
    final value = entry.value;
    if (value is Map && value['isCompleted'] == true) {
      totalPoints += ((value['marksEarned'] as num?) ?? 0).toInt();
    }
  }

  print('🟢 Points from completed subtopics: $totalPoints');

  // Step 3: Load master content.json
  final contentString = await rootBundle.loadString('assets/content.json');
  final contentData = jsonDecode(contentString);
  final subjects = contentData['subjects'] as List;

  // Step 4: Loop through units to check for complete units
  for (final subject in subjects) {
    final grades = subject['grades'];
    if (grades is! List) continue;

    for (final grade in grades) {
      final gradeLabel = grade['grade']; // Keep this string (e.g., "Grade 2")
      final units = grade['units'];
      if (units is! List) continue;

      for (final unit in units) {
        final subtopics = unit['subtopics'];
        if (subtopics is! List || subtopics.isEmpty) continue;

        final allCompleted = subtopics.every((sub) {
          final subId = sub['subtopic_id'];
          return userProgress[subId]?['isCompleted'] == true;
        });

        if (allCompleted) {
          print('✅ All subtopics completed for unit in $gradeLabel');

          final xpDoc =
              await firestore.collection('xp_master').doc(gradeLabel).get();
          if (xpDoc.exists && xpDoc.data()?['unit'] != null) {
            final unitXP = (xpDoc.data()!['unit'] as num).toInt();
            totalPoints += unitXP;
            print('🎁 Added $unitXP bonus XP from xp_master/$gradeLabel');
          }
        } else {
          print('❌ Unit in $gradeLabel is NOT fully completed');
        }
      }
    }
  }

  print('🔵 Total points after unit bonuses: $totalPoints');

  // Step 5: Find user level from level_master
  final levelQuery = await firestore
      .collection('level_master')
      .where('minimum_point', isLessThanOrEqualTo: totalPoints)
      .where('maximum_point', isGreaterThanOrEqualTo: totalPoints)
      .limit(1)
      .get();

  int currentLevel = 0;
  if (levelQuery.docs.isNotEmpty) {
    currentLevel = levelQuery.docs.first.data()['Level'] ?? 1;
  }

  return {
    'totalPoints': totalPoints,
    'currentLevel': currentLevel,
  };
}
