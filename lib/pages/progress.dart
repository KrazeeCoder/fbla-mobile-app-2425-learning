import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_mobile_2425_learning_app/firebase_utility.dart';
import 'package:fbla_mobile_2425_learning_app/widgets/recent_lessons_progress.dart';
import 'package:flutter/material.dart';
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
    processDataFromFirebase();
  }

  Future<void> processDataFromFirebase() async {
    try {
      FirestoreService _firestoreService =
      FirestoreService(); // Create instance

      List<String>? lessonData =
      await _firestoreService.getCompletedSubtopics();
      int? streakData = await _firestoreService.getStreak();

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

      int tempLevel = 37;

      Map<String, dynamic> tempData = {
        "streak": streakData ?? 0, // Use real streak data
        "lessons": processLessonData(tempLesson),
        "level": tempLevel
      };

      setState(() {
        _data = tempData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  Map<String, List<Map<String, dynamic>>> processLessonData(
      List<Map<String, dynamic>> subtopicsCompleted) {
    Map<String, List<Map<String, dynamic>>> recentLessons = {
      "math": [],
      "english": [],
      "science": [],
      "history": []
    };

    for (var subtopic in subtopicsCompleted) {
      String subject = subtopic["subject"].toLowerCase();
      if (recentLessons.containsKey(subject)) {
        recentLessons[subject]!.add(subtopic);
      }
    }

    return recentLessons;
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
