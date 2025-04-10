import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_mobile_2425_learning_app/minigames/racing_game.dart';
import 'package:fbla_mobile_2425_learning_app/minigames/word_scramble_game.dart';
import 'package:fbla_mobile_2425_learning_app/minigames/quiz_challenge_game.dart';
import 'package:fbla_mobile_2425_learning_app/utils/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../jsonUtility.dart';
import '../minigames/cypher_game.dart';
import '../minigames/maze_game.dart';
import '../minigames/puzzle_game.dart';
import '../widgets/subtopic_widget.dart';
import '../utils/subTopicNavigation.dart';

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
                          allSteps: steps, // <-- pass all steps here
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Grade ${widget.grade}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subject,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSeparator(String title) {
    // Extract unit number from title (e.g., "Unit 1: Number Sense" -> "1")
    final unitNumber = title.split(':')[0].replaceAll(RegExp(r'[^0-9]'), '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[50]!,
              Colors.grey[100]!,
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue[400]!,
                      Colors.blue[600]!,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    unitNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Complete all steps to progress",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPathwayStep({
    required Map<String, dynamic> step,
    required int index,
    required List<Map<String, dynamic>> allSteps,
  }) {
    final bool isCompleted = step["isCompleted"] ?? false;
    final bool isNextToDo = step["isNextToDo"] ?? false;
    final bool isInteractive = isCompleted || isNextToDo;
    final String title = step["title"] ?? "";
    final bool isSubtopic = step["type"] == "subtopic";

    // Check if this is the last step in the unit
    final bool isLastInUnit = _isLastInUnit(step, allSteps);

    return Padding(
      padding: EdgeInsets.only(
        left: 12.0,
        right: 12.0,
        top: 0.0,
        bottom: isLastInUnit ? 2.0 : 0.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineSection(index, isCompleted, isNextToDo, isSubtopic),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: isInteractive
                  ? () => _handleStepTap(
                      context, step, allSteps, title, isCompleted)
                  : null,
              child: _buildStepCard(
                  step, isCompleted, isNextToDo, title, isSubtopic),
            ),
          ),
        ],
      ),
    );
  }

  bool _isLastInUnit(
      Map<String, dynamic> step, List<Map<String, dynamic>> allSteps) {
    final currentUnitId = step["unitId"];
    final currentIndex = allSteps.indexOf(step);

    // Check if there's another step in the same unit after this one
    for (int i = currentIndex + 1; i < allSteps.length; i++) {
      if (allSteps[i]["type"] == "unit_separator") {
        return true;
      }
      if (allSteps[i]["unitId"] == currentUnitId) {
        return false;
      }
    }
    return true;
  }

  Widget _buildTimelineSection(
      int index, bool isCompleted, bool isNextToDo, bool isSubtopic) {
    return Column(
      children: [
        if (index > 0)
          Container(
            width: 2,
            height: 13,
            color: isCompleted ? Colors.green : Colors.grey[300],
          ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green[50]
                : isNextToDo
                    ? Colors.blue[50]
                    : Colors.grey[100],
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted
                  ? Colors.green
                  : isNextToDo
                      ? Colors.blue
                      : Colors.grey[400]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isSubtopic ? Icons.menu_book : Icons.videogame_asset,
            color: isCompleted
                ? Colors.green[700]
                : isNextToDo
                    ? Colors.blue[700]
                    : Colors.grey[600],
            size: 18,
          ),
        ),
        Container(
          width: 2,
          height: 13,
          color: isCompleted ? Colors.green : Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildStepCard(Map<String, dynamic> step, bool isCompleted,
      bool isNextToDo, String title, bool isSubtopic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted
              ? Colors.green[300]!
              : isNextToDo
                  ? Colors.blue[300]!
                  : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTypeBadge(isSubtopic),
              const SizedBox(width: 6),
              if (isCompleted)
                _buildStatusBadge(
                    "Completed", Icons.check_circle, Colors.green),
              if (isNextToDo)
                _buildStatusBadge("Next", Icons.arrow_forward, Colors.blue),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isCompleted
                  ? Colors.green[800]
                  : isNextToDo
                      ? Colors.blue[800]
                      : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(bool isSubtopic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isSubtopic ? Colors.purple[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isSubtopic ? "Reading" : "Game",
        style: TextStyle(
          color: isSubtopic ? Colors.purple[700] : Colors.orange[700],
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color.shade700),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              color: color.shade700,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _handleStepTap(BuildContext context, Map<String, dynamic> step,
      List<Map<String, dynamic>> allSteps, String title, bool isCompleted) {
    if (step["type"] == 'subtopic') {
      final unitSubtopics = allSteps
          .where(
              (s) => s["type"] == "subtopic" && s["unitId"] == step["unitId"])
          .toList();
      final gradeSubtopics = allSteps
          .where((s) => s["type"] == "subtopic" && s["grade"] == widget.grade)
          .toList();
      final subjectSubtopics = allSteps
          .where(
              (s) => s["type"] == "subtopic" && s["subject"] == widget.subject)
          .toList();

      final lastSubtopicOfUnit = unitSubtopics.isNotEmpty &&
          step["subIndex"] < unitSubtopics.length &&
          step["subIndex"] == unitSubtopics.length - 1;
      final lastSubtopicOfGrade = gradeSubtopics.isNotEmpty &&
          step["subIndex"] < gradeSubtopics.length &&
          step["subIndex"] == gradeSubtopics.length - 1;
      final lastSubtopicOfSubject = subjectSubtopics.isNotEmpty &&
          step["subIndex"] < subjectSubtopics.length &&
          step["subIndex"] == subjectSubtopics.length - 1;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubtopicPage(
            subtopic: title,
            subtopicId: step["subId"] ?? "",
            readingTitle: title,
            readingContent: step["reading"] ?? "",
            isCompleted: isCompleted,
            subject: widget.subject,
            grade: widget.grade,
            unitId: step["unitId"] ?? "",
            unitTitle: step["unitTitle"] ?? "",
            userId: widget.userId ?? '',
            lastSubtopicofUnit: lastSubtopicOfUnit,
            lastSubtopicofGrade: lastSubtopicOfGrade,
            lastSubtopicofSubject: lastSubtopicOfSubject,
          ),
        ),
      ).then((_) {
        setState(() {
          _pathwayData = parsePathwayData();
        });
      });
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

      final lastSubtopicOfUnit = step["subIndex"] ==
          (allSteps
                  .where((s) =>
                      s["type"] == "game" && s["unitId"] == step["unitId"])
                  .length -
              1);

      final lastSubtopicOfGrade = step["subIndex"] ==
          (allSteps
                  .where(
                      (s) => s["type"] == "game" && s["grade"] == widget.grade)
                  .length -
              1);

      final lastSubtopicOfSubject = step["subIndex"] ==
          (allSteps
                  .where((s) =>
                      s["type"] == "game" && s["subject"] == widget.subject)
                  .length -
              1);

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
          lastSubtopicofUnit: lastSubtopicOfUnit,
          lastSubtopicofGrade: lastSubtopicOfGrade,
          lastSubtopicofSubject: lastSubtopicOfSubject,
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
        QuizChallengeGame(
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
          lastSubtopicofUnit: lastSubtopicOfUnit,
          lastSubtopicofGrade: lastSubtopicOfGrade,
          lastSubtopicofSubject: lastSubtopicOfSubject,
        ),
      ];

      // Add WordScrambleGame only for History or English subjects
      if (widget.subject.toLowerCase() == "history" ||
          widget.subject.toLowerCase() == "english") {
        games.add(
          WordScrambleGame(
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
            lastSubtopicofUnit: lastSubtopicOfUnit,
            lastSubtopicofGrade: lastSubtopicOfGrade,
            lastSubtopicofSubject: lastSubtopicOfSubject,
          ),
        );
      }
      games.shuffle(); // ✅ Randomize order
      print(games.first);
      print(widget.subject);
      print(widget.grade);
      print(step["unitId"]);
      print(step["unitTitle"]);
      print(step["subId"]);
      print(step["title"]);
      print(step["nextSubtopicId"]);
      print(step["nextSubtopicTitle"]);
      print(step["nextReadingContent"]);
      print(widget.userId);
      print(lastSubtopicOfUnit);
      print(lastSubtopicOfGrade);
      print(lastSubtopicOfSubject);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => games.first),
      ).then((_) {
        setState(() {
          _pathwayData = parsePathwayData();
        });
      });
    }
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
