import 'package:fbla_mobile_2425_learning_app/firebase_utility.dart';
import 'package:flutter/material.dart';
import 'dart:core';

import '../jsonUtility.dart';

class PathwayUI extends StatefulWidget {
  final int grade;
  final String subject;

  PathwayUI({required this.grade, required this.subject});

  @override
  State<PathwayUI> createState() => _PathwayUIState();
}

class _PathwayUIState extends State<PathwayUI> {
  Future<List<Map<String, dynamic>>>? _pathwayData;

  @override
  void initState() {
    super.initState();
    _pathwayData = parsePathwayData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Pathway'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pathwayData,
        builder: (context, snapshot) {
          int stepPos = 0;
          int offset = 0;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pathway data available.'));
          } else {
            final steps = snapshot.data!;
            return ListView.builder(
              reverse: true,
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                if (step["type"] == "unit_separator") {
                  return _buildUnitSeparator(step["title"]);
                } else {
                  stepPos++;
                  offset++;
                  return _buildPathwayStep(
                    stepType: step["type"],
                    isCompleted: step["isCompleted"],
                    index: stepPos,
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildUnitSeparator(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: Colors.grey[400], thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Divider(color: Colors.grey[400], thickness: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildPathwayStep({required String stepType, required bool isCompleted, required int index}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const List<double> offsets = [0.65, 0.55, 0.45, 0.35, 0.25, 0.35, 0.45, 0.55,];
    double horizontalOffset = offsets[index%8]*screenWidth;

    return Padding(
      padding: EdgeInsets.only(left: horizontalOffset),
      child: PathwayStep(
        stepType: stepType,
        isCompleted: isCompleted,
      ),
    );
  }

  Future<List<Map<String, dynamic>>> parsePathwayData() async {
    Map<String, dynamic> data = await loadJsonData();
    List<Map<String, dynamic>> pathwayList = [];
    FirestoreService firestoreService = FirestoreService();
    List<Map<String, dynamic>>? completed = await firestoreService.getCompleted();

    // Iterate through subjects
    for (Map<String, dynamic> subjectMap in data["subjects"]) {
      if (subjectMap["name"].toLowerCase() == widget.subject.toLowerCase()) {
        // Iterate through grades
        for (Map<String, dynamic> gradeMap in subjectMap["grades"]) {
          if (gradeMap["grade"].toLowerCase() == "grade ${widget.grade.toString()}") {
            // Safely cast gradeMap["units"] to List<Map<String, dynamic>>
            List<Map<String, dynamic>> units = List<Map<String, dynamic>>.from(gradeMap["units"]);

            // Build pathwayList from units
            for (int i = 0; i < units.length; i++) {
              pathwayList.add({
                "type": "unit_separator",
                "title": "Unit ${i + 1}: ${units[i]["unit"]}"
              });

              // Add subtopics
              List<Map<String, dynamic>> subtopics = List<Map<String, dynamic>>.from(units[i]["subtopics"]);
              for (int j = 0; j < subtopics.length; j++) {
                pathwayList.add({
                  "type": "subtopic",
                  "title": subtopics[j]["subtopic"],
                  "isCompleted": completed?.any((map) => map.containsKey("id") && map["id"] == subtopics[j]["subtopic_id"] && map["type"] == "subtopic"),
                });

                pathwayList.add({
                  "type": "game",
                  "title": subtopics[j]["subtopic"],
                  "isCompleted": completed?.any((map) => map.containsKey("id") && map["id"] == subtopics[j]["subtopic_id"] && map["type"] == "game"),
                });
              }
            }
          }
        }
      }
    }

    return pathwayList;
  }
}

class PathwayStep extends StatelessWidget {
  final String stepType;
  final bool isCompleted;

  // Map to associate stepType with icons
  static const Map<String, IconData> stepTypeIcons = {
    "game": Icons.videogame_asset, // Game icon
    "subtopic": Icons.menu_book, // Learn icon
    "quiz": Icons.quiz, // Quiz icon
  };

  PathwayStep({required this.stepType, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    // Get the icon based on stepType, default to a generic icon if stepType is not found
    final IconData icon = stepTypeIcons[stepType] ?? Icons.help_outline;

    return Stack(
      clipBehavior: Clip.none, // Allow children to overflow without clipping
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.all(30),
            side: BorderSide(
              color: isCompleted ? Colors.green : Colors.grey,
              width: 1,
            ),
            shape: CircleBorder(),
            backgroundColor: isCompleted ? Colors.green[100] : Colors.grey[200],
          ),
          onPressed: ()=>{},
          child: Icon(
            icon,
            color: isCompleted ? Colors.green : Colors.grey,
          ),
        ),
        if (isCompleted)
          Positioned(
            top: -10,
            left: 50,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }


}