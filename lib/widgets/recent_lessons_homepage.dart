import 'package:fbla_mobile_2425_learning_app/widgets/subtopic_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'lessons.dart';

class RecentLessonsPage extends StatefulWidget {
  const RecentLessonsPage({super.key});

  @override
  _RecentLessonsPageState createState() => _RecentLessonsPageState();
}

class _RecentLessonsPageState extends State<RecentLessonsPage> {
  List<String> completedSubtopics = [];

  Future<void> fetchUserCompletedLessons() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user_completed')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc['completed'] != null) {
        List<dynamic> fetchedSubtopics = userDoc['completed'];

        setState(() {
          completedSubtopics = fetchedSubtopics
              .where((item) => item['type'] == 'subtopic') // Filter by type
              .map<String>((item) => item['id'] as String) // Extract id
              .toList();
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<List<Map<String, dynamic>>> loadCompletedLessons() async {
    String jsonString = await rootBundle.loadString('assets/content.json');
    Map<String, dynamic> data = json.decode(jsonString);
    List<Map<String, dynamic>> lessons = [];

    for (var subject in data['subjects']) {
      for (var grade in subject['grades']) {
        for (var unit in grade['units']) {
          for (var subtopic in unit['subtopics']) {
            String subtopicId = subtopic['subtopic_id'];

            if (completedSubtopics.contains(subtopicId)) {
              lessons.add({
                'subject': subject['name'],
                'grade': grade['grade'],
                'unit': unit['unit'],
                'subtopic': subtopic['subtopic'],
                'subtopicId': subtopicId,
                'readingTitle': subtopic['reading']['title'],
                'readingContent': subtopic['reading']['content'],
              });
            }
          }
        }
      }
    }
    return lessons;
  }

  @override
  void initState() {
    super.initState();
    fetchUserCompletedLessons();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: loadCompletedLessons(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No recently completed lessons.'));
        }

        final lessons = snapshot.data!;

        // Use Column instead of ListView.builder to make it non-scrollable
        return Column(
          children: lessons.map((lesson) {
            return LessonCard(
              lesson: Lesson(
                subject: lesson['subject'],
                grade: lesson['grade'],
                unit: lesson['unit'],
                subtopic: lesson['subtopic'],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubtopicPage(
                      subtopic: lesson['subtopic'],
                      subtopicId: lesson['subtopicId'],
                      readingTitle: lesson['readingTitle'],
                      readingContent: lesson['readingContent'],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}