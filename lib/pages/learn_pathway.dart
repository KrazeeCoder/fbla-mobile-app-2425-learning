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
      appBar: AppBar(
        title: Text('Learning Pathway'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.school, color: Colors.white, size: 28),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grade ${widget.grade}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      widget.subject,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
              ),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _pathwayData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Loading your learning path...',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
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
                          Text(
                            'Error loading pathway',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline,
                              size: 48, color: Colors.blue),
                          SizedBox(height: 16),
                          Text(
                            'No pathway data available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please check back later',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  } else {
                    final steps = snapshot.data!;
                    int stepPos = 0;
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 24),
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
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSeparator(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Row(
          children: [
            Icon(Icons.bookmark_border, color: Colors.blue, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
    required int unitId,
    required String unitTitle,
  }) {
    void navigate() {
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
              unitId: unitId,
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: navigate,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 60,
                child: Stack(
                  children: [
                    if (index > 0)
                      Positioned(
                        left: 19,
                        top: -30,
                        bottom: 0,
                        child: Container(
                          width: 2,
                          color:
                              isCompleted ? Colors.green : Colors.grey.shade300,
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 12,
                      child: PathwayStep(
                        stepType: stepType,
                        isCompleted: isCompleted,
                        isNextToDo: isNextToDo,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 36,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isNextToDo
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3)
                          : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      subtopicTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isNextToDo
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
  final VoidCallback onTap;

  static const Map<String, IconData> stepTypeIcons = {
    "game": Icons.videogame_asset,
    "subtopic": Icons.menu_book,
    "quiz": Icons.quiz,
  };

  PathwayStep({
    required this.stepType,
    required this.isCompleted,
    this.isNextToDo = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon = stepTypeIcons[stepType] ?? Icons.help_outline;
    final Color borderColor = isCompleted
        ? Colors.green
        : isNextToDo
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade300;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        color: isCompleted ? Colors.green.shade50 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: CircleBorder(),
              child: Center(
                child: Icon(icon, color: borderColor, size: 16),
              ),
            ),
          ),
          if (isNextToDo)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PathwayConnector extends CustomPainter {
  final bool isCompleted;
  final Color color;

  PathwayConnector({
    required this.isCompleted,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      size.height / 2,
      size.width / 2,
      0,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PathwayConnector oldDelegate) {
    return oldDelegate.isCompleted != isCompleted || oldDelegate.color != color;
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
