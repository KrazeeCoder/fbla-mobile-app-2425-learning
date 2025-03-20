import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ChooseLessonPage extends StatefulWidget {
  const ChooseLessonPage({super.key});

  @override
  _ChooseLessonPageState createState() => _ChooseLessonPageState();
}

class _ChooseLessonPageState extends State<ChooseLessonPage> {
  Map<String, dynamic>? contentData;
  String? selectedSubject;
  List<Map<String, dynamic>> availableGrades = [];
  List<int> completedSubtopics = [];

  @override
  void initState() {
    super.initState();
    loadJsonData();
    fetchUserCompletedLessons();
  }

  Future<void> loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/content.json');
    setState(() {
      contentData = json.decode(jsonString);
    });
  }

  Future<void> fetchUserCompletedLessons() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user_subtopics')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc['subtopicsCompleted'] != null) {
        List<dynamic> completedList = userDoc['subtopicsCompleted'];
        setState(() {
          completedSubtopics = completedList.map<int>((item) => item['subtopicId'] as int).toList();
        });
      }
    } catch (e) {
      print("❌ Error fetching user completed lessons: $e");
    }
  }

  void updateGrades() {
    if (selectedSubject == null || contentData == null) return;

    var subjectData = contentData!['subjects']
        .firstWhere((s) => s['name'] == selectedSubject, orElse: () => null);

    if (subjectData != null && subjectData['grades'] is List) {
      availableGrades = (subjectData['grades'] as List)
          .map((g) => {
        'grade': g['grade'].toString().replaceAll("Grade ", ""),
        'subtopics': g['units']
            .expand((unit) => unit['subtopics'] as List)
            .map((sub) => {
          'subtopic_id': sub['subtopic_id'],
          'subtopic': sub['subtopic'],
        })
            .toList(),
      })
          .toList();
    } else {
      availableGrades = [];
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Lesson")),
      body: const Center(child: Text("Lesson selection goes here!")),
    );
  }
}
