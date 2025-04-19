import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../coach_marks/showcase_keys.dart';
import '../jsonUtility.dart';
import '../widgets/subtopic_widget.dart';
import '../utils/game_launcher.dart';
import '../coach_marks/showcase_provider.dart';

class PathwayUI extends StatefulWidget {
  final int grade;
  final String subject;
  String? userId;
  final String? highlightSubtopicId;
  final VoidCallback onBackRequested;

  PathwayUI({
    required this.grade,
    required this.subject,
    this.userId,
    this.highlightSubtopicId,
    required this.onBackRequested,
  });

  @override
  State<PathwayUI> createState() => _PathwayUIState();
}

class _PathwayUIState extends State<PathwayUI> {
  Future<List<Map<String, dynamic>>>? _pathwayData;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _subtopicKeys = {};

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
      backgroundColor: Colors.grey.shade50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 15),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              height: kToolbarHeight + 12,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  children: [
                    // Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: widget.onBackRequested,
                      tooltip:
                          MaterialLocalizations.of(context).backButtonTooltip,
                    ),
                    // Icon and Title - Simplified
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Grade and Subject - Main focus with enhanced styling and better contrast
                          Row(
                            children: [
                              Text(
                                'Grade ${widget.grade}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2.0,
                                      color: Color.fromARGB(100, 0, 0, 0),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 1,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                widget.subject,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2.0,
                                      color: Color.fromARGB(100, 0, 0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Learning Pathway - Secondary text
                          Text(
                            'Learning Pathway',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Info Button
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.info_outline,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            // Show info about the learning pathway
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'This pathway shows your learning journey'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          tooltip: 'Pathway Info',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

      ),
      body: Column(
        children: [
          // Space to compensate for the floating AppBar - reduced
          const SizedBox(height: 0),
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

                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    BuildContext? targetContext;
                    // Case 1: Scroll to explicitly passed subtopic

                    if (widget.highlightSubtopicId != null &&
                        _subtopicKeys.containsKey(widget.highlightSubtopicId)) {
                      print("Scrolling to explicitly passed subtopic");
                      targetContext = _subtopicKeys[widget.highlightSubtopicId]!
                          .currentContext;
                      if (targetContext != null) {
                        await Scrollable.ensureVisible(
                          targetContext,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeInOut,
                        );
                      }
                    }
                    // Case 2: Scroll to first blue step (next to do)
                    else {
                      print("Scrolling to first blue step");
                      print(_subtopicKeys.entries.last);
                      final nextToDoEntry = _subtopicKeys.entries.firstWhere(
                        (e) => steps.any((s) =>
                            s['subId'] == e.key &&
                            s['type'] != 'unit_separator' &&
                            s['isNextToDo'] == true),
                        orElse: () {
                          print("No blue step found, scrolling to bottom");
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                          );
                          return MapEntry(
                              '', GlobalKey()); // Return dummy entry
                        },
                      );

                      // Only try to scroll if a valid next step was found
                      if (nextToDoEntry.key.isNotEmpty) {
                        targetContext = nextToDoEntry.value.currentContext;
                        if (targetContext != null) {
                          await Scrollable.ensureVisible(
                            targetContext,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                          );
                        }
                      }
                    }

                    // Trigger showcase AFTER scrolling is complete
                    // Use the context from the main ShowCaseWidget
                    if (mounted && targetContext != null) {
                      final showcaseService =
                          Provider.of<ShowcaseService>(context, listen: false);
                      // Get the ShowCaseWidget context from the main widget tree
                      final showcaseContext = ShowCaseWidget.of(context);
                      if (showcaseContext != null) {
                        // ❗ Only start if showcase hasn't been completed/skipped
                        if (!showcaseService.hasCompletedInitialShowcase) {
                          showcaseService.startPathwayScreenShowcase(context);
                        }
                      }
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      final step = steps[index];
                      if (step["type"] == "unit_separator") {
                        return _buildUnitSeparator(step["title"]);
                      } else {
                        stepPos++;
                        if (step["isNextToDo"] == true) {
                          return _buildPathwayStepWithShowcase(
                            step: step,
                            index: stepPos,
                            allSteps: steps, // <-- pass all steps here
                          );
                        } else {
                          return _buildPathwayStep(
                            step: step,
                            index: stepPos,
                            allSteps: steps, // <-- pass all steps here
                          );
                        }
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

    final String subId = step["subId"] ?? '';
    final key = GlobalKey();
    if (!_subtopicKeys.containsKey(subId)) {
      _subtopicKeys[subId] = key;
    }

    return KeyedSubtree(
      key: key,
      child: Padding(
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
      ),
    );
  }

  Widget _buildPathwayStepWithShowcase({
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

    final String subId = step["subId"] ?? '';
    final key = GlobalKey();
    if (!_subtopicKeys.containsKey(subId)) {
      _subtopicKeys[subId] = key;
    }

    return KeyedSubtree(
      key: key,
      child: Showcase(
        key: ShowcaseKeys.pathwayStepKey,
        title: 'Pathway Step',
        description:
            'Tap here to view the lesson content or start the practice game.',
        onTargetClick: () {
          _handleStepTap(context, step, allSteps, title, isCompleted);
        },
        disposeOnTap: true,
        child: Padding(
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
        ),
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
    return Stack(
      children: [
        Container(
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
                  if (step["fromRecent"] == true)
                    _buildStatusBadge(
                        "You clicked", Icons.touch_app, Colors.purple),
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
        ),

        // 🔵 Subtle pointer for Next To Do
        if (isNextToDo)
          Positioned(
            left: 0,
            top: 12,
            bottom: 12,
            child: Container(
              width: 6,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
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
            builder: (context) => ShowCaseWidget(
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
          )).then((_) {
        setState(() {
          _pathwayData = parsePathwayData();
        });
        // Trigger showcase after returning
        if (mounted) {
          final showcaseService =
              Provider.of<ShowcaseService>(context, listen: false);
          // ❗ Only start if showcase hasn't been completed/skipped
          if (!showcaseService.hasCompletedInitialShowcase) {
            showcaseService.startPathwayToProgressScreenShowcase(context);
          }
        }
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

      launchRandomGame(
        context: context,
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
      ).then((_) {
        setState(() {
          _pathwayData = parsePathwayData();
        });
        // Trigger showcase after returning
        if (mounted) {
          final showcaseService =
              Provider.of<ShowcaseService>(context, listen: false);
          // ❗ Only start if showcase hasn't been completed/skipped
          if (!showcaseService.hasCompletedInitialShowcase) {
            showcaseService.startPathwayToProgressScreenShowcase(context);
          }
        }
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
                final isFromRecent = subId == widget.highlightSubtopicId;

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
                  "fromRecent": isFromRecent,
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
                  "fromRecent": isFromRecent,
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
