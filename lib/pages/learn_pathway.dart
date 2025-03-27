import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../jsonUtility.dart';
import '../minigames/cypher_game.dart';
import '../minigames/maze_game.dart';
import '../minigames/puzzle_game.dart';
import '../widgets/subtopic_widget.dart';

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

  Widget _buildUnitSeparator(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[400], thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(title,
                style: TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.w500)),
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
            List<Map<String, dynamic>> units =
                List<Map<String, dynamic>>.from(gradeMap["units"]);

            for (int i = 0; i < units.length; i++) {
              rawSteps.add({
                "type": "unit_separator",
                "title": "Unit ${i + 1}: ${units[i]["unit"]}"
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
