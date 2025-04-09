import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../minigames/maze_game.dart';
import '../minigames/puzzle_game.dart';
import '../minigames/cypher_game.dart';
import '../pages/lesson_chatbot.dart';
import '../services/updateprogress.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../xp_manager.dart';
import '../utils/app_logger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'earth_unlock_animation.dart';
import 'package:audioplayers/audioplayers.dart';

class SubtopicPage extends StatelessWidget {
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

  const SubtopicPage({
    Key? key, // 👈 optional, not required
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
  }) : super(key: key);

  void launchRandomGame(BuildContext context) {
    final nextSubtopicId = "dummy_last";
    final nextSubtopicTitle = "Last subtopic";
    final nextReadingContent = "";
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
    final games = [
      CypherUI(
        subject: subject,
        grade: grade,
        unitId: unitId,
        unitTitle: unitTitle,
        subtopicTitle: readingTitle,
        subtopicId: subtopicId,
        nextSubtopicId: nextSubtopicId,
        nextSubtopicTitle: nextSubtopicTitle,
        nextReadingContent: nextReadingContent,
        userId: currentUserId,
      ),
      MazeGame(
        subject: subject,
        grade: grade,
        unitId: unitId,
        unitTitle: unitTitle,
        subtopicTitle: readingTitle,
        subtopicId: subtopicId,
        nextSubtopicId: nextSubtopicId,
        nextSubtopicTitle: nextSubtopicTitle,
        nextReadingContent: nextReadingContent,
        userId: currentUserId,
      ),
      PuzzleScreen(
        subject: subject,
        grade: grade,
        unitId: unitId,
        unitTitle: unitTitle,
        subtopicTitle: readingTitle,
        subtopicId: subtopicId,
        nextSubtopicId: nextSubtopicId,
        nextSubtopicTitle: nextSubtopicTitle,
        nextReadingContent: nextReadingContent,
        userId: currentUserId,
      ),
    ];
    games.shuffle();

    debugPrint(
        '[SubtopicPage → Game Launch] subtopic: $subtopicId | next: $nextSubtopicTitle ($nextSubtopicId)');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => games.first),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    // Define green color scheme
    final Color primaryGreen = Colors.green.shade600;
    final Color lightGreen = Colors.green.shade100;
    final Color mediumGreen = Colors.green.shade300;
    final Color darkGreen = Colors.green.shade800;

    return Scaffold(
      appBar: AppBar(
        title: Text(subtopic),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            // Increase bottom padding to prevent content from being cut off
            padding: const EdgeInsets.only(bottom: 120),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Card with decoration
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          mediumGreen,
                          lightGreen,
                        ],
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
                          readingTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.book,
                              size: 16,
                              color: darkGreen,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Grade $grade · $subject · $unitTitle",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: darkGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content with Markdown
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
                      data: readingContent,
                      styleSheet: MarkdownStyleSheet(
                        h1: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                          height: 1.4,
                        ),
                        h2: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: primaryGreen,
                          height: 1.4,
                        ),
                        h3: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: primaryGreen.withOpacity(0.85),
                          height: 1.4,
                        ),
                        p: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                        strong: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        em: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade800,
                        ),
                        listBullet: TextStyle(
                          color: primaryGreen,
                        ),
                        blockquote: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade700,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
                        blockquoteDecoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border(
                            left: BorderSide(
                              color: primaryGreen.withOpacity(0.5),
                              width: 4,
                            ),
                          ),
                        ),
                        tableHead: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        tableBody: const TextStyle(
                          fontSize: 16,
                        ),
                        tableColumnWidth: const FixedColumnWidth(150),
                        tableBorder: TableBorder.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      selectable: true,
                      softLineBreak: true,
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          url_launcher.launchUrl(Uri.parse(href));
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Completion message card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          isCompleted ? Colors.green.shade100 : lightGreen,
                          isCompleted
                              ? Colors.green.shade50
                              : Colors.green.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCompleted
                            ? Colors.green.withOpacity(0.3)
                            : primaryGreen.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCompleted ? Icons.celebration : Icons.task_alt,
                          color:
                              isCompleted ? Colors.green.shade700 : darkGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isCompleted
                                ? "🎉 You've already completed this subtopic!"
                                : "✅ Great job! Now as the next step, click below to continue.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isCompleted
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              fontStyle: isCompleted
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                              color: isCompleted
                                  ? Colors.green.shade700
                                  : darkGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Add extra space at the bottom
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom action buttons
          if (!isCompleted)
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
                      // Chat button moved to the left side
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatbotScreen(topicId: subtopicId),
                            ),
                          );
                        },
                        backgroundColor: lightGreen,
                        foregroundColor: darkGreen,
                        child: const Icon(Icons.chat_bubble_outline),
                        tooltip: "Ask Chat-it",
                      ),
                      const SizedBox(width: 16),
                      // Expanded button takes remaining space
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;

                            if (user != null) {
                              // 1️ Mark subtopic completed in user_progress
                              await markSubtopicAsCompleted(
                                subtopicId: subtopicId,
                                subtopicTitle: readingTitle,
                                unitTitle: unitTitle,
                                grade: grade,
                                unitId: unitId,
                                subject: subject,
                              );

                              // 2️⃣ Update resume point for game launch
                              await updateResumePoint(
                                userId: user.uid,
                                subject: subject,
                                grade: 'Grade $grade',
                                unitId: unitId,
                                unitName: unitTitle,
                                subtopicId: subtopicId,
                                subtopicName: subtopic,
                                actionType: 'content',
                                actionState: 'completed',
                              );

                              // 3️⃣ Launch next puzzle/game
                              launchRandomGame(context);

                              // Add XP for completing the subtopic
                              _awardXPForCompletion(context);
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

  // Add XP for completing the subtopic
  void _awardXPForCompletion(BuildContext context) {
    try {
      // Access the XP manager
      final xpManager = Provider.of<XPManager>(context, listen: false);

      // Add XP and handle level up
      xpManager.addXP(5, onLevelUp: (newLevel) {
        // Show the custom earth unlock animation instead of the default
        _showEarthUnlockedAnimation(context, newLevel);
      });

      // Show a brief XP notification
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

  // Show custom level up animation with earth unlocked
  void _showEarthUnlockedAnimation(BuildContext context, int newLevel) {
    EarthUnlockAnimation.show(context, newLevel);
  }
}
