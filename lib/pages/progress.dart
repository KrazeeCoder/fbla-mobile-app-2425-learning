import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_mobile_2425_learning_app/services/progress_service.dart';
import 'package:fbla_mobile_2425_learning_app/widgets/recent_lessons_progress.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_logger.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  int streak = 0;
  int level = 0;
  int subtopicsCompleted = 0;
  Map<String, dynamic> userProgress = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProgressData();
  }

  Future<void> fetchProgressData() async {
    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // 🔹 Get user progress from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('user_progress')
          .doc(uid)
          .get();
      userProgress = snapshot.data() ?? {};

      // 🔹 Calculate subtopics completed
      subtopicsCompleted = await getTotalSubtopicsCompleted(uid);
      // 🔹 Calculate level and total points using new method
      final levelData = await calculateLevelAndPoints(uid);
      level = levelData['currentLevel'];

      // 🔹 Optionally: update streak if you have logic for it
      streak = 4; // Replace with real streak logic if needed

      setState(() => _isLoading = false);
    } catch (e) {
      AppLogger.e("Error fetching progress data", error: e);
      setState(() => _isLoading = false);
    }
  }

  Future<int> getTotalSubtopicsCompleted(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user_progress')
        .doc(uid)
        .get();

    final data = snapshot.data() ?? {};
    int count = 0;

    for (final entry in data.entries) {
      if (entry.value is Map && entry.value['isCompleted'] == true) {
        count++;
      }
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                          "$streak day streak!",
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
                      _StatCard(label: "levels achieved", value: "$level"),
                      _StatCard(
                          label: "subtopics completed",
                          value: "$subtopicsCompleted"),
                    ],
                  ),
                  Expanded(
                    child: RecentLessonsTabWidget(
                      userProgress: userProgress,
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
