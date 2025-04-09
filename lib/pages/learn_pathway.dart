import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_mobile_2425_learning_app/minigames/racing_game.dart';
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
  String? userId;

  PathwayUI({required this.grade, required this.subject, this.userId});

  @override
  State<PathwayUI> createState() => _PathwayUIState();
}

class _PathwayUIState extends State<PathwayUI> {
  Future<List<Map<String, dynamic>>>? _pathwayData;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    widget.userId = user?.uid ?? '';
    _pathwayData = parsePathwayData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Pathway'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _pathwayData,
              builder: (context, snapshot) {
                int stepPos = 0;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No pathway data available.'));
                } else {
                  final steps = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      final step = steps[index];
                      if (step["type"] == "unit_separator") {
                        return _buildUnitSeparator(step["title"]);
                      } else {
                        stepPos++;
                        return _buildPathwayStep(
                          step: step,
                          index: stepPos,
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8)
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grade ${widget.grade}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              Text(
                widget.subject,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildUnitSeparator(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
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
    required Map<String, dynamic> step,
    required int index,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
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
        stepType: step["type"],
        isCompleted: step["isCompleted"],
        isNextToDo: step["isNextToDo"] ?? false,
        onTap: (step["isCompleted"] || (step["isNextToDo"] ?? false))
            ? () {
                if (step["type"] == 'subtopic') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubtopicPage(
                        subtopic: step["title"],
                        subtopicId: step["subId"],
                        readingTitle: step["title"],
                        readingContent: step["reading"] ?? "",
                        isCompleted: step["isCompleted"],
                        subject: widget.subject,
                        grade: widget.grade,
                        unitId: step["unitId"],
                        unitTitle: step["unitTitle"],
                        userId: widget.userId ?? '',
                      ),
                    ),
                  );
                } else if (step["type"] == 'game') {
                  final nextSubtopicData = {
                    "title": step["nextSubtopicTitle"],
                    "subId": step["nextSubtopicId"],
                    "reading": step["nextReadingContent"],
                    "subject": widget.subject,
                    "grade": widget.grade,
                    "unitId": step["unitId"],
                    "unitTitle": step["unitTitle"],
                    "userId": widget.userId ?? '',
                  };
                  final games = [
                    RacingGame(
                      subject: widget.subject,
                      grade: widget.grade,
                      unitId: step["unitId"],
                      unitTitle: step["unitTitle"],
                      subtopicId: step["subId"],
                      subtopicTitle: step["title"],
                      nextSubtopicId: step["nextSubtopicId"],
                      nextSubtopicTitle: step["nextSubtopicTitle"],
                      nextReadingContent: step["nextReadingContent"],
                      userId: widget.userId ?? '',
                    ),
                    CypherUI(
                      subject: widget.subject,
                      grade: widget.grade,
                      unitId: step["unitId"],
                      unitTitle: step["unitTitle"],
                      subtopicId: step["subId"],
                      subtopicTitle: step["title"],
                      nextSubtopicId: step["nextSubtopicId"],
                      nextSubtopicTitle: step["nextSubtopicTitle"],
                      nextReadingContent: step["nextReadingContent"],
                      userId: widget.userId ?? '',
                    ),
                    MazeGame(
                      subject: widget.subject,
                      grade: widget.grade,
                      unitId: step["unitId"],
                      unitTitle: step["unitTitle"],
                      subtopicId: step["subId"],
                      subtopicTitle: step["title"],
                      nextSubtopicId: step["nextSubtopicId"],
                      nextSubtopicTitle: step["nextSubtopicTitle"],
                      nextReadingContent: step["nextReadingContent"],
                      userId: widget.userId ?? '',
                    ),
                    PuzzleScreen(
                      subject: widget.subject,
                      grade: widget.grade,
                      unitId: step["unitId"],
                      unitTitle: step["unitTitle"],
                      subtopicId: step["subId"],
                      subtopicTitle: step["title"],
                      nextSubtopicId: step["nextSubtopicId"],
                      nextSubtopicTitle: step["nextSubtopicTitle"],
                      nextReadingContent: step["nextReadingContent"],
                      userId: widget.userId ?? '',
                    ),
                  ];
                  games.shuffle(); // ✅ Randomize order
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

    for (var subjectMap in data["subjects"]) {
      if (subjectMap["name"].toLowerCase() == widget.subject.toLowerCase()) {
        for (var gradeMap in subjectMap["grades"]) {
          if (gradeMap["grade"].toLowerCase() ==
              "grade ${widget.grade.toString()}") {
            final units = List<Map<String, dynamic>>.from(gradeMap["units"]);

            for (int i = 0; i < units.length; i++) {
              rawSteps.add({
                "type": "unit_separator",
                "title": "Unit ${i + 1}: ${units[i]["unit"]}",
              });

              final subtopics =
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

                Map<String, dynamic>? nextSub;
                if (j + 1 < subtopics.length) {
                  nextSub = subtopics[j + 1];
                } else if (i + 1 < units.length) {
                  final nextUnitSubs = List<Map<String, dynamic>>.from(
                      units[i + 1]["subtopics"]);
                  if (nextUnitSubs.isNotEmpty) {
                    nextSub = nextUnitSubs.first;
                  }
                }

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
                  "nextSubtopicId": nextSub?["subtopic_id"] ?? "dummy_last",
                  "nextSubtopicTitle": nextSub?["subtopic"] ?? "Last subtopic",
                  "nextReadingContent": nextSub?["reading"]?["content"] ?? "",
                });
              }
            }
          }
        }
      }
    }

    final matchedIndex = rawSteps.indexWhere(
        (step) => step["type"] != "unit_separator" && step["isResume"] == true);

    if (matchedIndex != -1) {
      for (int i = 0; i < matchedIndex; i++) {
        if (rawSteps[i]["type"] != "unit_separator") {
          rawSteps[i]["isCompleted"] = true;
        }
      }

      if (resumeStatus == 'in_progress') {
        rawSteps[matchedIndex]["isNextToDo"] = true;
      } else if (resumeStatus == 'completed') {
        rawSteps[matchedIndex]["isCompleted"] = true;
        for (int i = matchedIndex + 1; i < rawSteps.length; i++) {
          if (rawSteps[i]["type"] != "unit_separator") {
            rawSteps[i]["isNextToDo"] = true;
            break;
          }
        }
      }
    } else {
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

  const PathwayStep({
    required this.stepType,
    required this.isCompleted,
    required this.isNextToDo,
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
