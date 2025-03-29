import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_mobile_2425_learning_app/firebase_utility.dart';
import 'package:fbla_mobile_2425_learning_app/widgets/recent_lessons_progress.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../jsonUtility.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    processAllDataFromFirebase();
  }

  Future<void> processAllDataFromFirebase() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // ✅ Load user progress
      final snapshot = await FirebaseFirestore.instance
          .collection('user_progress')
          .doc(uid)
          .get();
      final userProgress = snapshot.data() ?? {};

      // ✅ Lessons: parsed from Firestore step records (subtopics)
      List<Map<String, dynamic>> lessonData = await parseCompletedSteps();
      FirestoreService firestoreService = FirestoreService();
      int? streakData = await firestoreService.getStreak();
      int? levelData = await firestoreService.getLevel();

      Map<String, dynamic> allData = {
        "streak": streakData ?? 0,
        "lessons": lessonData,
        "level": levelData,
        "userProgress": userProgress, // ✅ included
      };

      setState(() {
        _data = allData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> parseCompletedSteps() async {
    final Map<String, dynamic> jsonData = await loadJsonData();
    FirestoreService firestoreService = FirestoreService();
    List<Map<String, dynamic>>? completedSteps =
        await firestoreService.getCompleted();

    List<Map<String, dynamic>> result = [];

    for (var step in completedSteps!) {
      if (step["type"] == "subtopic") {
        final String subtopicId = step["id"];
        final DateTime datetime = step["datetime"].toDate();

        for (var subject in jsonData["subjects"]) {
          for (var grade in subject["grades"]) {
            for (var unit in grade["units"]) {
              for (var subtopic in unit["subtopics"]) {
                if (subtopic["subtopic_id"] == subtopicId) {
                  result.add({
                    "subject": subject["name"],
                    "grade": int.parse(
                        grade["grade"].replaceAll(RegExp('[^0-9]'), '')),
                    "subtopic_id": subtopicId,
                    "datetime": datetime,
                  });
                  break;
                }
              }
            }
          }
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data == null || _data!.isEmpty
              ? const Center(child: Text('No data found.'))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[100],
                          foregroundColor: Colors.deepOrange,
                          elevation: 8,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department_sharp,
                                color: Colors.deepOrange, size: 30),
                            const SizedBox(width: 8),
                            Text(
                              "${_data!["streak"]} day streak!",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Levels Achieved
                          _StatCard(
                            label: "levels achieved",
                            value: _data!["level"].toString(),
                          ),

                          // Subtopics Completed
                          _StatCard(
                            label: "subtopics completed",
                            value: _data!["lessons"].length.toString(),
                          ),
                        ],
                      ),
                      Expanded(
                        child: RecentLessonsTabWidget(
                          userProgress: _data!["userProgress"], // ✅ passed here
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF358A2B),
          shadowColor: Colors.lightGreenAccent,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          fixedSize: const Size(150, 150),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 50)),
            Text(label,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
