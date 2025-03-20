import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_mobile_2425_learning_app/firebase_utility.dart';
import 'package:fbla_mobile_2425_learning_app/widgets/recent_lessons_progress.dart';
import 'package:flutter/material.dart';
import '../jsonUtility.dart';
import '../widgets/earth_widget.dart';
import 'package:fbla_mobile_2425_learning_app/main.dart';

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
      List<Map<String, dynamic>> lessonData = await parseCompletedSteps();
      FirestoreService firestoreService = FirestoreService(); // Create instance
      int? streakData = await firestoreService.getStreak();
      int? levelData = await firestoreService.getLevel();
      List<Map<String, dynamic>> tempLesson = [
        {"ID": 1, "subject": "math", "grade": "2"},
        {"ID": 2, "subject": "math", "grade": "2"},
        {"ID": 3, "subject": "math", "grade": "2"},
        {"ID": 4, "subject": "math", "grade": "2"},
        {"ID": 5, "subject": "math", "grade": "2"},
        {"ID": 7, "subject": "math", "grade": "2"},
        {"ID": 1, "subject": "math", "grade": "3"},
        {"ID": 2, "subject": "english", "grade": "2"},
        {"ID": 1, "subject": "english", "grade": "2"},
        {"ID": 1, "subject": "science", "grade": "2"},
      ];

      Map<String, dynamic> allData = {
        "streak": streakData ?? 0, // Use real streak data
        "lessons": lessonData,
        "level": levelData
      };

      setState(() {
        _data = allData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }


  Future<List<Map<String, dynamic>>> parseCompletedSteps() async {
    final Map<String, dynamic> jsonData = await loadJsonData();
    FirestoreService firestoreService = FirestoreService();
    List<Map<String, dynamic>>? completedSteps = await firestoreService.getCompleted();
    print(completedSteps);

    // Result list
    List<Map<String, dynamic>> result = [];

    // Iterate through completed steps
    for (var step in completedSteps!) {
      // Check if the step is a subtopic
      if (step["type"] == "subtopic") {
        final String subtopicId = step["id"];
        final DateTime datetime = step["datetime"].toDate(); // Convert Firestore timestamp to DateTime

        // Search for the subtopic in the JSON data
        for (var subject in jsonData["subjects"]) {
          for (var grade in subject["grades"]) {
            for (var unit in grade["units"]) {
              for (var subtopic in unit["subtopics"]) {
                if (subtopic["subtopic_id"] == subtopicId) {
                  // Add the result to the list
                  result.add({
                    "subject": subject["name"],
                    "grade": int.parse(grade["grade"].replaceAll(RegExp('[^0-9]'), '')),
                    "subtopic_id": subtopicId,
                    "datetime": datetime,
                  });
                  break; // Exit the inner loop once the subtopic is found
                }
              }
            }
          }
        }
      }
    }
    print(result);

    return result;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _data == null || _data!.isEmpty
          ? Center(child: Text('No data found.'))
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[100],
                foregroundColor: Colors.deepOrange,
                elevation: 8,
                padding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department_sharp,
                      color: Colors.deepOrange, size: 30),
                  SizedBox(width: 8),
                  Text(
                    "${_data!["streak"]} day streak!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly, // Evenly space the buttons
              children: [
                // First Button
                Container(
                  padding: EdgeInsets.all(
                      16), // Add padding around the button
                  child: ElevatedButton(
                    onPressed: () => {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Color(0xFF358A2B), // Light green background
                      shadowColor: Colors
                          .lightGreenAccent, // Glow effect color
                      elevation:
                      10, // Add a slight glow with elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            12), // Slightly rounded corners
                      ),
                      fixedSize:
                      Size(150, 150), // Make the button square
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center content vertically
                      children: [
                        Text(
                          _data!["level"].toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 50),
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          "levels achieved",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),

                // Second Button
                Container(
                  padding: EdgeInsets.all(
                      16), // Add padding around the button
                  child: ElevatedButton(
                    onPressed: () => {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Color(0xFF358A2B), // Light green background
                      shadowColor: Colors
                          .lightGreenAccent, // Glow effect color
                      elevation:
                      10, // Add a slight glow with elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            12), // Slightly rounded corners
                      ),
                      fixedSize:
                      Size(150, 150), // Make the button square
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center content vertically
                      children: [
                        Text(
                          _data!["lessons"].length.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 50),
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          "subtopics completed",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: RecentLessonsTabWidget(
                  lessonsData: _data!["lessons"]),
            ),
          ],
        ),
      ),
    );
  }
}
