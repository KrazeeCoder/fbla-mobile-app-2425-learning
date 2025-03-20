import 'package:fbla_mobile_2425_learning_app/widgets/subtopic_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'lessons.dart';


class RecentLessonsPage extends StatefulWidget {
  const RecentLessonsPage({super.key});

  @override
  _RecentLessonsPageState createState() => _RecentLessonsPageState();
}

class _RecentLessonsPageState extends State<RecentLessonsPage> {
  List<int> completedSubtopics = [];

  Future<void> fetchUserCompletedLessons() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc('SKFMYGD4oclNQ2focMJN')
          .get();

      if (userDoc.exists) {
        setState(() {
          completedSubtopics = List<int>.from(userDoc['subtopicsCompleted']);
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
            int subtopicId = subtopic['subtopic_id'];
            if (completedSubtopics.contains(subtopicId)) {
              lessons.add({
                'subject': subject['name'],
                'grade': grade['grade'],
                'unit': unit['unit'],
                'subtopic': subtopic['subtopic'],
                'subtopicId': subtopicId, // Pass subtopicId
                'readingTitle': subtopic['reading']['title'],
                'readingContent': subtopic['reading']['content']
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

        return ListView.builder(
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];

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
                      subtopicId: lesson['subtopicId'], // Pass subtopicId
                      readingTitle: lesson['readingTitle'],
                      readingContent: lesson['readingContent'],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
