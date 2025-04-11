import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../minigames/maze_game.dart';
import '../minigames/puzzle_game.dart';
import '../minigames/cypher_game.dart';
import '../minigames/racing_game.dart';
import '../minigames/quiz_challenge_game.dart';
import '../minigames/word_scramble_game.dart';
import '../pages/lesson_chatbot.dart';
import '../services/updateprogress.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../xp_manager.dart';
import '../utils/app_logger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'earth_unlock_animation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/subTopicNavigation.dart';
import '../utils/game_launcher.dart';

class SubtopicPage extends StatefulWidget {
  final String subtopic;
  final String subtopicId;
  final String readingTitle;
  final String readingContent;
  final bool isCompleted;
  final String subject;
  final int grade;
  final int unitId;
  final String unitTitle;
  final String userId;
  final bool lastSubtopicofUnit;
  final bool lastSubtopicofGrade;
  final bool lastSubtopicofSubject;

  const SubtopicPage({
    Key? key,
    required this.subtopic,
    required this.subtopicId,
    required this.readingTitle,
    required this.readingContent,
    required this.isCompleted,
    required this.subject,
    required this.grade,
    required this.unitId,
    required this.unitTitle,
    required this.userId,
    required this.lastSubtopicofUnit,
    required this.lastSubtopicofGrade,
    required this.lastSubtopicofSubject,
  }) : super(key: key);

  @override
  State<SubtopicPage> createState() => _SubtopicPageState();
}

class _SubtopicPageState extends State<SubtopicPage> {
  late bool _isCompleted;
  Map<String, dynamic>? subtopicNav;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.isCompleted;
    _checkSubtopicCompletion();

    getSubtopicNavigationInfo(
      subject: widget.subject,
      grade: widget.grade,
      subtopicId: widget.subtopicId,
    ).then((value) {
      setState(() {
        subtopicNav = value;
      });
    });

    // Ensure progress and resume point are created only after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HandleSubTopicStart(
        subtopicId: widget.subtopicId,
        subtopicTitle: widget.readingTitle,
        unitTitle: widget.unitTitle,
        grade: widget.grade,
        unitId: widget.unitId,
        subject: widget.subject,
      );
    });
  }

  Future<void> _checkSubtopicCompletion() async {
    bool completed = await isSubtopicCompleted(
      userId: widget.userId,
      subject: widget.subject,
      grade: 'Grade ${widget.grade}',
      subtopicId: widget.subtopicId,
    );

    if (mounted) {
      setState(() {
        _isCompleted = completed;
      });
    }
  }

/*
  void launchRandomGame(BuildContext context) {
    final nextSubtopicId = subtopicNav?['nextSubtopicId'] ?? "";
    final nextSubtopicTitle = subtopicNav?['nextReadingTitle'] ?? "";
    final nextReadingContent = subtopicNav?['nextReadingContent'] ?? "";
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    final games = [
      CypherUI(
        subject: widget.subject,
        grade: widget.grade,
        unitId: widget.unitId,
        unitTitle: widget.unitTitle,
        subtopicTitle: widget.readingTitle,
        subtopicId: widget.subtopicId,
        nextSubtopicId: nextSubtopicId,
        nextSubtopicTitle: nextSubtopicTitle,
        nextReadingContent: nextReadingContent,
        userId: currentUserId,
      ),
      MazeGame(
        subject: widget.subject,
        grade: widget.grade,
        unitId: widget.unitId,
        unitTitle: widget.unitTitle,
        subtopicTitle: widget.readingTitle,
        subtopicId: widget.subtopicId,
        nextSubtopicId: nextSubtopicId,
        nextSubtopicTitle: nextSubtopicTitle,
        nextReadingContent: nextReadingContent,
        userId: currentUserId,
      ),
      PuzzleScreen(
        subject: widget.subject,
        grade: widget.grade,
        unitId: widget.unitId,
        unitTitle: widget.unitTitle,
        subtopicTitle: widget.readingTitle,
        subtopicId: widget.subtopicId,
        nextSubtopicId: nextSubtopicId,
        nextSubtopicTitle: nextSubtopicTitle,
        nextReadingContent: nextReadingContent,
        userId: currentUserId,
      ),
      RacingGame(
        subject: widget.subject,
        grade: widget.grade,
        unitId: widget.unitId,
        unitTitle: widget.unitTitle,
        subtopicTitle: widget.readingTitle,
        subtopicId: widget.subtopicId,
        nextSubtopicId: nextSubtopicId,
        nextSubtopicTitle: nextSubtopicTitle,
        nextReadingContent: nextReadingContent,
        userId: currentUserId,
      ),
      QuizChallengeGame(
        subject: widget.subject,
        grade: widget.grade,
        unitId: widget.unitId,
        unitTitle: widget.unitTitle,
        subtopicTitle: widget.readingTitle,
        subtopicId: widget.subtopicId,
        nextSubtopicId: nextSubtopicId,
        nextSubtopicTitle: nextSubtopicTitle,
        nextReadingContent: nextReadingContent,
        userId: currentUserId,
      ),
    ];

    // Add WordScrambleGame only for specific subjects
    if (widget.subject.toLowerCase() == "english" ||
        widget.subject.toLowerCase() == "history") {
      games.add(
        WordScrambleGame(
          subject: widget.subject,
          grade: widget.grade,
          unitId: widget.unitId,
          unitTitle: widget.unitTitle,
          subtopicTitle: widget.readingTitle,
          subtopicId: widget.subtopicId,
          nextSubtopicId: nextSubtopicId,
          nextSubtopicTitle: nextSubtopicTitle,
          nextReadingContent: nextReadingContent,
          userId: currentUserId,
        ),
      );
    }

    games.shuffle();

    debugPrint(
      '[SubtopicPage → Game Launch] subtopic: ${widget.subtopicId} | launching: ${games.first.runtimeType}',
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => games.first),
    ).then((_) => _checkSubtopicCompletion());
  }
*/
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final Color primaryGreen = Colors.green.shade600;
    final Color lightGreen = Colors.green.shade100;
    final Color mediumGreen = Colors.green.shade300;
    final Color darkGreen = Colors.green.shade800;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subtopic),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 120),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [mediumGreen, lightGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.readingTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.book, size: 16, color: darkGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Grade ${widget.grade} · ${widget.subject} · ${widget.unitTitle}",
                                style:
                                    TextStyle(fontSize: 14, color: darkGreen),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: MarkdownBody(
                      data: widget.readingContent,
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          url_launcher.launchUrl(Uri.parse(href));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _isCompleted ? Colors.green.shade100 : lightGreen,
                          _isCompleted
                              ? Colors.green.shade50
                              : Colors.green.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isCompleted
                            ? Colors.green.withOpacity(0.3)
                            : primaryGreen.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isCompleted ? Icons.celebration : Icons.task_alt,
                          color:
                              _isCompleted ? Colors.green.shade700 : darkGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isCompleted
                                ? "🎉 You've already completed this subtopic!"
                                : "✅ Great job! Now as the next step, click below to continue.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _isCompleted
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              fontStyle: _isCompleted
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                              color: _isCompleted
                                  ? Colors.green.shade700
                                  : darkGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (!_isCompleted)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatbotScreen(topicId: widget.subtopicId),
                            ),
                          );
                        },
                        backgroundColor: lightGreen,
                        foregroundColor: darkGreen,
                        child: const Icon(Icons.chat_bubble_outline),
                        tooltip: "Ask Chat-it",
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;

                            if (user != null) {
                              _handleSubTopicCompletion(context);

                              await launchRandomGame(
                                context: context,
                                subject: widget.subject,
                                grade: widget.grade,
                                unitId: widget.unitId,
                                unitTitle: widget.unitTitle,
                                subtopicId: widget.subtopicId,
                                subtopicTitle: widget.readingTitle,
                                nextSubtopicId:
                                    subtopicNav?['nextSubtopicId'] ?? "",
                                nextSubtopicTitle:
                                    subtopicNav?['nextReadingTitle'] ?? "",
                                nextReadingContent:
                                    subtopicNav?['nextReadingContent'] ?? "",
                                userId: widget.userId,
                              );

                              _checkSubtopicCompletion(); // ✅ Refresh state after game
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text("Continue to Practice",
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future _handleSubTopicCompletion(BuildContext context) async {
    setState(() {
      _isCompleted = true;
    });

    await markSubtopicAsCompleted(
      subtopicId: widget.subtopicId,
      subtopicTitle: widget.readingTitle,
      unitTitle: widget.unitTitle,
      grade: widget.grade,
      unitId: widget.unitId,
      subject: widget.subject,
    );

    await updateResumePoint(
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      subject: widget.subject,
      grade: 'Grade ${widget.grade}',
      unitId: widget.unitId,
      unitName: widget.unitTitle,
      subtopicId: widget.subtopicId,
      subtopicName: widget.subtopic,
      actionType: 'content',
      actionState: 'completed',
    );

    _awardXPForCompletion(context);

    return; // Ensure the method always returns a Future
  }

  void _awardXPForCompletion(BuildContext context) {
    try {
      final xpManager = Provider.of<XPManager>(context, listen: false);
      xpManager.addXP(5, onLevelUp: (newLevel) {
        showEarthUnlockedAnimation(
            context, newLevel, widget.subject, widget.subtopic);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+ 5 XP earned!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      AppLogger.e('Error awarding XP: $e');
    }
  }
}
