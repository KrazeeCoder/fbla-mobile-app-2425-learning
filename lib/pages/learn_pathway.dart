import 'package:fbla_mobile_2425_learning_app/firebase_utility.dart';
import 'package:flutter/material.dart';
import 'dart:core';

import '../jsonUtility.dart';
import '../widgets/subtopic_widget.dart';
import '../minigames/puzzle_game.dart';

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
        backgroundColor: Color(0xFF358A2B),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF0F8FF)],
          ),
        ),
        child: Column(
          children: [
            // Grade and Subject Indicator
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5A95E5), Color(0xFF7EACF0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
                border: Border.all(color: Color(0xFF4A8FE7).withOpacity(0.3)),
              ),
              margin: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A8FE7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Learning Journey',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        'Grade ${widget.grade} - ${widget.subject}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Pathway Steps
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _pathwayData,
                builder: (context, snapshot) {
                  int stepPos = 0;

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF4A8FE7)),
                          SizedBox(height: 16),
                          Text('Loading your learning pathway...',
                              style: TextStyle(color: Color(0xFF4A8FE7)))
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text('Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline,
                              size: 48, color: Colors.amber),
                          SizedBox(height: 16),
                          Text('No pathway data available.',
                              style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    );
                  } else {
                    final steps = snapshot.data!;
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      width: double.infinity,
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        reverse: false,
                        itemCount: steps.length,
                        padding: EdgeInsets.only(top: 10, bottom: 60),
                        itemBuilder: (context, index) {
                          final step = steps[index];
                          if (step["type"] == "unit_separator") {
                            // Check if we need to add connecting lines before/after separators
                            bool showLineAbove = index > 0 &&
                                steps[index - 1]["type"] != "unit_separator";
                            bool showLineBelow = index < steps.length - 1 &&
                                steps[index + 1]["type"] != "unit_separator";

                            // Extract the progress data
                            final double progress = step["progress"] ?? 0.0;
                            final int completedActivities =
                                step["completedActivities"] ?? 0;
                            final int totalActivities =
                                step["totalActivities"] ?? 0;

                            // Debug output for unit separator data
                            print(
                                "Displaying Unit: ${step["title"]} - Progress: $completedActivities/$totalActivities (${(progress * 100).toStringAsFixed(1)}%)");

                            return Center(
                              child: Column(
                                children: [
                                  // Show connecting line above separator if needed
                                  if (showLineAbove)
                                    Container(
                                      width: 4,
                                      height: 25,
                                      color: Color(0xFFDFE8EC),
                                    ),

                                  _buildUnitSeparator(
                                    step["title"],
                                    progress: progress,
                                    completedActivities: completedActivities,
                                    totalActivities: totalActivities,
                                  ),

                                  // Show connecting line below separator if needed
                                  if (showLineBelow)
                                    Container(
                                      width: 4,
                                      height: 25,
                                      color: Color(0xFFDFE8EC),
                                    ),
                                ],
                              ),
                            );
                          } else {
                            stepPos++;
                            return Center(
                              child: _buildPathwayStep(
                                stepType: step["type"],
                                isCompleted: step["isCompleted"] ?? false,
                                index: stepPos,
                                subtopicId: step["subtopicId"],
                                title: step["title"],
                                content: step["content"],
                                readingTitle: step["readingTitle"],
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSeparator(String title,
      {double progress = 0.0,
      int completedActivities = 0,
      int totalActivities = 0}) {
    // Extract unit number if present (e.g., "Unit 1: Mathematics" → "1")
    String unitNumber = "";
    if (title.contains("Unit") && title.contains(":")) {
      final RegExp regex = RegExp(r'Unit (\d+):');
      final match = regex.firstMatch(title);
      if (match != null && match.groupCount >= 1) {
        unitNumber = match.group(1) ?? "";
      }
    }

    // Extract content after colon (e.g., "Unit 1: Mathematics" → "Mathematics")
    String unitContent = title.contains(": ") ? title.split(": ")[1] : title;

    // Determine if unit is complete
    bool isComplete = progress >= 1.0;

    // Color based on completion
    Color unitColor = isComplete
        ? Color(0xFF43A047) // Green
        : progress > 0.5
            ? Color(0xFF388E3C) // Darker green
            : Color(0xFF2E7D32); // Base green

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      width: MediaQuery.of(context).size.width * 0.85,
      child: Row(
        children: [
          Container(
            width: 110,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circle background
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isComplete
                            ? [Color(0xFF66BB6A), Color(0xFF43A047)]
                            : [Color(0xFF2E7D32), Color(0xFF43A047)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF358A2B).withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  // Unit number or completion check
                  if (isComplete)
                    Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  else if (unitNumber.isNotEmpty)
                    Text(
                      unitNumber,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  else
                    Icon(
                      Icons.bookmark,
                      color: Colors.white,
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isComplete
                      ? [Color(0xFF66BB6A), Color(0xFF43A047)]
                      : [Color(0xFF2E7D32), Color(0xFF43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF358A2B).withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isComplete ? Icons.emoji_events : Icons.school,
                        color: Colors.white.withOpacity(0.9),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          unitContent,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isComplete)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 12,
                              ),
                              SizedBox(width: 2),
                              Text(
                                "100%",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isComplete)
                              Text(
                                "COMPLETED",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            else if (unitNumber.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "UNIT $unitNumber",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    " · $completedActivities/$totalActivities",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                "$completedActivities/$totalActivities",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 8),
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                width: (progress * 100).clamp(0, 100) /
                                    100 *
                                    MediaQuery.of(context).size.width *
                                    0.4, // Scale progress bar based on container width
                                decoration: BoxDecoration(
                                  color: isComplete
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: isComplete
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            blurRadius: 4,
                                            offset: Offset(0, 0),
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathwayStep({
    required String stepType,
    required bool isCompleted,
    required int index,
    String? subtopicId,
    String? title,
    String? content,
    String? readingTitle,
  }) {
    // Get the step color based on the step type
    final Color stepColor = isCompleted
        ? Color(0xFF4CAF50)
        : (PathwayStep.stepTypeColors[stepType] ?? Colors.grey);

    // Calculate constants for positioning
    final double nodeSize = 50;
    final double lineHeight = 25;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top connecting line
        if (index > 1)
          Container(
            width: 4,
            height: lineHeight,
            color: isCompleted
                ? Color(0xFF8BC34A).withOpacity(0.5)
                : Color(0xFFDFE8EC),
          ),

        // Main node with label
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left-aligned main node
              Container(
                width: 110,
                child: Center(
                  child: InkWell(
                    onTap: () => _navigateToContent(context, stepType,
                        subtopicId, title, content, readingTitle),
                    customBorder: CircleBorder(),
                    child: Container(
                      width: nodeSize,
                      height: nodeSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? stepColor : Colors.white,
                        border: Border.all(
                          color: isCompleted
                              ? Colors.transparent
                              : Color(0xFFDFE8EC),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          PathwayStep.stepTypeIcons[stepType] ??
                              Icons.help_outline,
                          color: isCompleted ? Colors.white : stepColor,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Label to the right (for all nodes)
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: isCompleted
                          ? stepColor.withOpacity(0.3)
                          : Color(0xFFEEEEEE),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: stepColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          stepType == "subtopic"
                              ? Icons.menu_book_outlined
                              : stepType == "game"
                                  ? Icons.videogame_asset_outlined
                                  : Icons.school_outlined,
                          size: 14,
                          color: stepColor,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title ?? "Activity",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Completion check
                      if (isCompleted)
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: stepColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom connecting line
        Container(
          width: 4,
          height: lineHeight,
          color: isCompleted
              ? Color(0xFF8BC34A).withOpacity(0.5)
              : Color(0xFFDFE8EC),
        ),
      ],
    );
  }

  // Function to navigate based on content type
  void _navigateToContent(
      BuildContext context,
      String stepType,
      String? subtopicId,
      String? title,
      String? content,
      String? readingTitle) async {
    if (subtopicId == null || subtopicId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Content not available')));
      return;
    }

    // Get the content directly from the JSON data
    Map<String, dynamic> jsonData = await loadJsonData();
    String readingContent = "Content not available";
    String actualReadingTitle = readingTitle ?? title ?? "Learning Content";

    // Search for the content in the JSON data
    for (var subject in jsonData["subjects"]) {
      for (var grade in subject["grades"]) {
        for (var unit in grade["units"]) {
          for (var subtopic in unit["subtopics"]) {
            if (subtopic["subtopic_id"] == subtopicId) {
              // Found the matching subtopic
              if (subtopic.containsKey("reading")) {
                readingContent = subtopic["reading"]["content"];
                if (subtopic["reading"].containsKey("title")) {
                  actualReadingTitle = subtopic["reading"]["title"];
                }
              }
              break;
            }
          }
        }
      }
    }

    if (stepType == "subtopic") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubtopicPage(
            subtopic: title ?? "Learning Content",
            subtopicId: subtopicId,
            readingTitle: actualReadingTitle,
            readingContent: readingContent,
          ),
        ),
      );
    } else if (stepType == "game") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PuzzleScreen(
            subtopicId: subtopicId,
          ),
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> parsePathwayData() async {
    Map<String, dynamic> data = await loadJsonData();
    List<Map<String, dynamic>> pathwayList = [];
    FirestoreService firestoreService = FirestoreService();
    List<Map<String, dynamic>>? completed =
        await firestoreService.getCompleted();

    // Create mock data for testing if completed is empty
    if (completed == null || completed.isEmpty) {
      print("No completed items found. Adding mock data for testing...");
      completed = [];

      // Iterate through subjects and add some mock completed items
      for (Map<String, dynamic> subjectMap in data["subjects"]) {
        if (subjectMap["name"].toLowerCase() == widget.subject.toLowerCase()) {
          for (Map<String, dynamic> gradeMap in subjectMap["grades"]) {
            if (gradeMap["grade"].toLowerCase() ==
                "grade ${widget.grade.toString()}") {
              List<Map<String, dynamic>> units =
                  List<Map<String, dynamic>>.from(gradeMap["units"]);

              // Add mock completed items for the first unit's first subtopic
              if (units.isNotEmpty && units[0]["subtopics"].isNotEmpty) {
                String mockSubtopicId = units[0]["subtopics"][0]["subtopic_id"];
                completed.add({
                  "id": mockSubtopicId,
                  "type": "subtopic",
                  "datetime": DateTime.now()
                });

                // Add more mock completed items
                if (units[0]["subtopics"].length > 1) {
                  String mockSubtopicId2 =
                      units[0]["subtopics"][1]["subtopic_id"];
                  completed.add({
                    "id": mockSubtopicId2,
                    "type": "subtopic",
                    "datetime": DateTime.now()
                  });
                  completed.add({
                    "id": mockSubtopicId2,
                    "type": "game",
                    "datetime": DateTime.now()
                  });
                }

                // Add mock for second unit if it exists
                if (units.length > 1 && units[1]["subtopics"].isNotEmpty) {
                  String mockSubtopicId3 =
                      units[1]["subtopics"][0]["subtopic_id"];
                  completed.add({
                    "id": mockSubtopicId3,
                    "type": "subtopic",
                    "datetime": DateTime.now()
                  });
                }
              }

              break;
            }
          }
          break;
        }
      }
    }

    // Iterate through subjects
    for (Map<String, dynamic> subjectMap in data["subjects"]) {
      if (subjectMap["name"].toLowerCase() == widget.subject.toLowerCase()) {
        // Iterate through grades
        for (Map<String, dynamic> gradeMap in subjectMap["grades"]) {
          if (gradeMap["grade"].toLowerCase() ==
              "grade ${widget.grade.toString()}") {
            // Safely cast gradeMap["units"] to List<Map<String, dynamic>>
            List<Map<String, dynamic>> units =
                List<Map<String, dynamic>>.from(gradeMap["units"]);

            // Build pathwayList from units
            for (int i = 0; i < units.length; i++) {
              // Calculate completion for this unit
              List<Map<String, dynamic>> subtopics =
                  List<Map<String, dynamic>>.from(units[i]["subtopics"]);

              int totalActivities = subtopics.length *
                  2; // Each subtopic has a learn and game activity
              int completedActivities = 0;

              for (int j = 0; j < subtopics.length; j++) {
                String subtopicId = subtopics[j]["subtopic_id"] ?? "";

                // Check subtopic completion
                bool isSubtopicCompleted = completed?.any((map) =>
                        map.containsKey("id") &&
                        map["id"] == subtopicId &&
                        map["type"] == "subtopic") ??
                    false;

                // Check game completion
                bool isGameCompleted = completed?.any((map) =>
                        map.containsKey("id") &&
                        map["id"] == subtopicId &&
                        map["type"] == "game") ??
                    false;

                if (isSubtopicCompleted) completedActivities++;
                if (isGameCompleted) completedActivities++;
              }

              // Calculate progress percentage with safety check
              double progress = 0.0;
              if (totalActivities > 0) {
                progress = completedActivities / totalActivities;
              }

              // Print debug information
              print(
                  "Unit ${i + 1}: ${completedActivities}/${totalActivities} = ${(progress * 100).toStringAsFixed(1)}%");

              // Add unit separator with completion info
              pathwayList.add({
                "type": "unit_separator",
                "title": "Unit ${i + 1}: ${units[i]["unit"]}",
                "completedActivities": completedActivities,
                "totalActivities": totalActivities,
                "progress": progress,
              });

              // If there are no subtopics, add a placeholder
              if (subtopics.isEmpty) {
                pathwayList.add({
                  "type": "subtopic",
                  "title": "Coming Soon",
                  "subtopicId": "",
                  "content": "Content will be added soon.",
                  "readingTitle": "Coming Soon",
                  "isCompleted": false,
                });
              } else {
                // Add subtopics
                for (int j = 0; j < subtopics.length; j++) {
                  String subtopicId = subtopics[j]["subtopic_id"] ?? "";
                  pathwayList.add({
                    "type": "subtopic",
                    "title": subtopics[j]["subtopic"],
                    "subtopicId": subtopicId,
                    "content": subtopics[j].containsKey("reading")
                        ? subtopics[j]["reading"]["content"]
                        : "Content not available",
                    "readingTitle": subtopics[j].containsKey("reading") &&
                            subtopics[j]["reading"].containsKey("title")
                        ? subtopics[j]["reading"]["title"]
                        : subtopics[j]["subtopic"],
                    "isCompleted": completed?.any((map) =>
                            map.containsKey("id") &&
                            map["id"] == subtopicId &&
                            map["type"] == "subtopic") ??
                        false,
                  });

                  pathwayList.add({
                    "type": "game",
                    "title": subtopics[j]["subtopic"],
                    "subtopicId": subtopicId,
                    "isCompleted": completed?.any((map) =>
                            map.containsKey("id") &&
                            map["id"] == subtopicId &&
                            map["type"] == "game") ??
                        false,
                  });
                }
              }
            }
          }
        }
      }
    }

    // Return the pathway list in reversed order for proper display
    return pathwayList.reversed.toList();
  }
}

class PathwayStep extends StatelessWidget {
  final String stepType;
  final bool isCompleted;
  final String? subtopicId;
  final String? title;
  final String? content;
  final String? readingTitle;

  // Map to associate stepType with icons
  static const Map<String, IconData> stepTypeIcons = {
    "game": Icons.videogame_asset,
    "subtopic": Icons.menu_book,
    "quiz": Icons.quiz,
  };

  // Map for step type color schemes - using varied colors
  static const Map<String, Color> stepTypeColors = {
    "game": Color(0xFFFF8A3D), // Orange for games
    "subtopic": Color(
        0xFF7B1FA2), // Purple for learning content (completely different from green)
    "quiz": Color(0xFF4A8FE7), // Blue for quizzes
  };

  PathwayStep({
    required this.stepType,
    required this.isCompleted,
    this.subtopicId,
    this.title,
    this.content,
    this.readingTitle,
  });

  void _navigateToContent(BuildContext context) async {
    if (subtopicId == null || subtopicId!.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Content not available')));
      return;
    }

    // Get the content directly from the JSON data
    Map<String, dynamic> jsonData = await loadJsonData();
    String readingContent = "Content not available";
    String actualReadingTitle = readingTitle ?? title ?? "Learning Content";

    // Search for the content in the JSON data
    for (var subject in jsonData["subjects"]) {
      for (var grade in subject["grades"]) {
        for (var unit in grade["units"]) {
          for (var subtopic in unit["subtopics"]) {
            if (subtopic["subtopic_id"] == subtopicId) {
              // Found the matching subtopic
              if (subtopic.containsKey("reading")) {
                readingContent = subtopic["reading"]["content"];
                if (subtopic["reading"].containsKey("title")) {
                  actualReadingTitle = subtopic["reading"]["title"];
                }
              }
              break;
            }
          }
        }
      }
    }

    if (stepType == "subtopic") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubtopicPage(
            subtopic: title ?? "Learning Content",
            subtopicId: subtopicId!,
            readingTitle: actualReadingTitle,
            readingContent: readingContent,
          ),
        ),
      );
    } else if (stepType == "game") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PuzzleScreen(
            subtopicId: subtopicId!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the icon based on stepType, default to a generic icon if stepType is not found
    final IconData icon = stepTypeIcons[stepType] ?? Icons.help_outline;
    final Color stepColor = isCompleted
        ? Color(0xFF1E7836) // Darker green for completed items
        : (stepTypeColors[stepType] ?? Colors.grey);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        clipBehavior: Clip.none, // Allow children to overflow without clipping
        children: [
          // Button with shadow and gradient
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: stepColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: CircleBorder(),
                onTap: () => _navigateToContent(context),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isCompleted
                          ? [
                              Color(0xFF60C050),
                              Color(0xFF1E7836)
                            ] // Green gradient for completed items
                          : [stepColor.withOpacity(0.7), stepColor],
                    ),
                    border: Border.all(
                      color: isCompleted
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      width: isCompleted ? 3 : 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          // Completion Check Badge
          if (isCompleted)
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFF1E7836), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: Color(0xFF1E7836),
                ),
              ),
            ),
          // Completion status on the opposite side
          if (isCompleted)
            Positioned(
              top: -5,
              left: -5,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFF1E7836), width: 1),
                ),
                child: Text(
                  "DONE",
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E7836),
                  ),
                ),
              ),
            ),
          // Type indicator
          Positioned(
            bottom: -10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isCompleted ? Color(0xFFE8F5E9) : Color(0xFFDFFFD6),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: isCompleted
                      ? Border.all(color: Color(0xFF1E7836), width: 1)
                      : null,
                ),
                child: Text(
                  stepType == "subtopic"
                      ? "Learn"
                      : stepType == "game"
                          ? "Game"
                          : stepType.capitalize(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: stepColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
