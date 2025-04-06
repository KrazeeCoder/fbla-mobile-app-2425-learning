import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../jsonUtility.dart';
import '../minigames/cypher_game.dart';
import '../minigames/maze_game.dart';
import '../minigames/puzzle_game.dart';
import '../widgets/subtopic_widget.dart';
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
      appBar: AppBar(title: Text('Learning Pathway')),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              border: Border(
                  bottom: BorderSide(
                      color: Colors.blue.withOpacity(0.2), width: 1)),
            ),
            child: Row(
              children: [
                Icon(Icons.school, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  'Grade ${widget.grade} - ${widget.subject}',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _pathwayData,
              builder: (context, snapshot) {
                int stepPos = 0;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No pathway data available.'));
                } else {
                  final steps = snapshot.data!;
                  return ListView.builder(
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      final step = steps[index];
                      if (step["type"] == "unit_separator") {
                        return _buildUnitSeparator(step["title"]);
                      } else {
                        stepPos++;
                        return _buildPathwayStep(
                          stepType: step["type"],
                          isCompleted: step["isCompleted"],
                          isNextToDo: step["isNextToDo"] ?? false,
                          index: stepPos,
                          subtopicTitle: step["title"],
                          subtopicId: step["subId"],
                          readingContent: step["reading"] ?? "",
                          unitId: step["unitId"],
                          unitTitle: step["unitTitle"],
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
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
          Expanded(child: Divider(color: Colors.grey[400], thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(title,
                style: TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.w500)),
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
          Expanded(child: Divider(color: Colors.grey[400], thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildPathwayStep({
    required String stepType,
    required bool isCompleted,
    required bool isNextToDo,
    required int index,
    required String subtopicTitle,
    required String subtopicId,
    required String readingContent,
    required int unitId, // ✅ add this
    required String unitTitle, // ✅ add this
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const List<double> offsets = [
      0.65,
      0.55,
      0.45,
      0.35,
      0.25,
      0.35,
      0.45,
      0.55
    ];
    double horizontalOffset = offsets[index % offsets.length] * screenWidth;

    return Padding(
      padding: EdgeInsets.only(left: horizontalOffset, bottom: 20),
      child: PathwayStep(
        stepType: stepType,
        isCompleted: isCompleted,
        isNextToDo: isNextToDo,
        onTap: (isCompleted || isNextToDo)
            ? () {
                if (stepType == 'subtopic') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubtopicPage(
                        subtopic: subtopicTitle,
                        subtopicId: subtopicId,
                        readingTitle: subtopicTitle,
                        readingContent: readingContent,
                        isCompleted: isCompleted,
                        subject: widget.subject,
                        grade: widget.grade,
                        unitId: unitId, // ✅ pass properly
                        unitTitle: unitTitle,
                      ),
                    ),
                  );
                } else if (stepType == 'game') {
                  final games = [
                    CypherUI(subtopicId: subtopicId),
                    MazeGame(subtopicId: subtopicId),
                    PuzzleScreen(subtopicId: subtopicId),
                  ];
                  games.shuffle();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => games.first),
                  );
                }
              }
            : null,
      ),
    );
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
    final data = await loadJsonData();
    List<Map<String, dynamic>> rawSteps = [];

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final docId =
        '${userId.replaceAll(':', '_')}_${widget.subject.replaceAll(' ', '')}_Grade${widget.grade}';

    final resumeSnapshot = await FirebaseFirestore.instance
        .collection('resume_points')
        .doc(docId)
        .get();
    final resumeData = resumeSnapshot.data();

    final resumeSubId = resumeData?['subtopic_id']?.toString();
    final resumeType = resumeData?['action_type'];
    final resumeStatus = resumeData?['action_state'];

    for (Map<String, dynamic> subjectMap in data["subjects"]) {
      if (subjectMap["name"].toLowerCase() == widget.subject.toLowerCase()) {
        for (Map<String, dynamic> gradeMap in subjectMap["grades"]) {
          if (gradeMap["grade"].toLowerCase() ==
              "grade ${widget.grade.toString()}") {
            // Safely cast gradeMap["units"] to List<Map<String, dynamic>>
            List<Map<String, dynamic>> units =
                List<Map<String, dynamic>>.from(gradeMap["units"]);
          if (gradeMap["grade"].toLowerCase() ==
              "grade ${widget.grade.toString()}") {
            List<Map<String, dynamic>> units =
                List<Map<String, dynamic>>.from(gradeMap["units"]);

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
              rawSteps.add({
                "type": "unit_separator",
                "title": "Unit ${i + 1}: ${units[i]["unit"]}",
                "completedActivities": completedActivities,
                "totalActivities": totalActivities,
                "progress": progress,
              });

              List<Map<String, dynamic>> subtopics =
                  List<Map<String, dynamic>>.from(units[i]["subtopics"]);

              for (int j = 0; j < subtopics.length; j++) {
                final sub = subtopics[j];
                final subId = sub["subtopic_id"].toString();

                final isResumeContent =
                    resumeType == 'content' && resumeSubId == subId;
                final isResumeGame =
                    resumeType == 'game' && resumeSubId == subId;

                rawSteps.add({
                  "type": "subtopic",
                  "title": sub["subtopic"],
                  "subId": subId,
                  "unit": i,
                  "unitId": units[i]["unit_id"],
                  "unitTitle": units[i]["unit"],
                  "subIndex": j,
                  "isResume": isResumeContent,
                  "isCompleted": false,
                  "reading": sub["reading"]?["content"] ?? "",
                });

                rawSteps.add({
                  "type": "game",
                  "title": sub["subtopic"],
                  "subId": subId,
                  "unit": i,
                  "unitId": units[i]["unit_id"],
                  "unitTitle": units[i]["unit"],
                  "subIndex": j,
                  "isResume": isResumeGame,
                  "isCompleted": false,
                });
              }
            }
          }
        }
      }
    }

    int matchedIndex = rawSteps.indexWhere(
      (step) => step["type"] != "unit_separator" && step["isResume"] == true,
    );

    if (matchedIndex != -1) {
      // ✅ Mark all previous steps as completed
      for (int i = 0; i < matchedIndex; i++) {
        if (rawSteps[i]["type"] != "unit_separator") {
          rawSteps[i]["isCompleted"] = true;
        }
      }

      if (resumeStatus == 'in_progress') {
        // ✅ Highlight current step
        rawSteps[matchedIndex]["isNextToDo"] = true;
      } else if (resumeStatus == 'completed') {
        // ✅ Mark current as completed too
        rawSteps[matchedIndex]["isCompleted"] = true;

        // ✅ Move to next actionable step
        for (int i = matchedIndex + 1; i < rawSteps.length; i++) {
          if (rawSteps[i]["type"] != "unit_separator") {
            rawSteps[i]["isNextToDo"] = true;
            break;
          }
        }
      }
    } else {
      // No match — fallback to first step
      for (int i = 0; i < rawSteps.length; i++) {
        if (rawSteps[i]["type"] != "unit_separator") {
          rawSteps[i]["isNextToDo"] = true;
          break;
        }
      }
    }

    return rawSteps;
  }
}

class PathwayStep extends StatelessWidget {
  final String stepType;
  final bool isCompleted;
  final bool isNextToDo;
  final VoidCallback? onTap;

  static const Map<String, IconData> stepTypeIcons = {
    "game": Icons.videogame_asset,
    "subtopic": Icons.menu_book,
    "quiz": Icons.quiz,
  };

  PathwayStep({
    required this.stepType,
    required this.isCompleted,
    this.isNextToDo = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon = stepTypeIcons[stepType] ?? Icons.help_outline;
    final Color borderColor = isCompleted
        ? Colors.green
        : isNextToDo
            ? Colors.blue
            : Colors.grey;
    final Color bgColor = isCompleted
        ? Colors.green[100]!
        : isNextToDo
            ? Colors.blue[100]!
            : Colors.grey[200]!;
    final Color iconColor = isCompleted
        ? Colors.green
        : isNextToDo
            ? Colors.blue
            : Colors.grey;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.all(30),
            side: BorderSide(color: borderColor, width: 1),
            shape: CircleBorder(),
            backgroundColor: bgColor,
          ),
          child: Icon(icon, color: iconColor),
        ),
      ],
    );
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

}
