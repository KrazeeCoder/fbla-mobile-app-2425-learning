import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class ChooseLessonController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> loadContentJson() async {
    String jsonString = await rootBundle.loadString('assets/content.json');
    return jsonDecode(jsonString);
  }

  Future<Map<String, dynamic>> getUserProgress() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return {};

    final snapshot =
        await _firestore.collection('user_progress').doc(userId).get();
    return snapshot.data() ?? {};
  }

  Future<List<Map<String, dynamic>>> getGradeCompletionData(
      String selectedSubject) async {
    final content = await loadContentJson();
    final progress = await getUserProgress();

    List<Map<String, dynamic>> gradeTiles = [];

    for (var subject in content['subjects']) {
      if (subject['name'] != selectedSubject) continue;

      for (var grade in subject['grades']) {
        int total = 0;
        int completed = 0;

        for (var unit in grade['units']) {
          for (var sub in unit['subtopics']) {
            total++;
            String subId = sub['subtopic_id'];
            if (progress.containsKey(subId) &&
                progress[subId]['isCompleted'] == true) {
              completed++;
            }
          }
        }

        double percentage = total > 0 ? (completed / total) * 100 : 0;

        gradeTiles.add({
          'grade': grade['grade'],
          'total': total,
          'completed': completed,
          'percent': percentage,
        });
      }
    }

    return gradeTiles;
  }
}
