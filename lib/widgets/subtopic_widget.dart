import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../minigames/maze_game.dart';
import '../minigames/puzzle_game.dart';
import '../minigames/cypher_game.dart';
import '../pages/chatbot_screen.dart';
import '../services/updateprogress.dart';
import 'package:audioplayers/audioplayers.dart'; // Add to pubspec.yaml
import '../widgets/subtopic_widget.dart'; // Assuming this shows subtopics

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
    return Scaffold(
      appBar: AppBar(
        title: Text(subtopic),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    readingTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._formatText(readingContent),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      isCompleted
                          ? "🎉 You’ve already completed this subtopic!"
                          : "✅ Great job! Now as the next step, click below to continue.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isCompleted ? FontWeight.w500 : FontWeight.normal,
                        fontStyle:
                            isCompleted ? FontStyle.normal : FontStyle.italic,
                        color: isCompleted
                            ? Colors.green[700]
                            : Colors.blueGrey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isCompleted)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
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

                            // 2️ Update resume point for game launch
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
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            const Text("Next", style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatbotScreen(topicId: subtopicId),
                              ),
                            );
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: const Icon(Icons.chat_bubble_outline),
                          tooltip: "Ask Chat-it",
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

  List<Widget> _formatText(String content) {
    List<Widget> widgets = [];
    List<String> lines = content.split("\n");

    for (String line in lines) {
      if (line.startsWith("### ")) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              line.replaceFirst("### ", ""),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        );
      } else if (line.startsWith("- ")) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(fontSize: 16)),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      children: _formatBoldText(line.replaceFirst("- ", "")),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: _formatBoldText(line),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  List<TextSpan> _formatBoldText(String text) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (var match in exp.allMatches(text)) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastMatchEnd = match.end;
    }

    spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    return spans;
  }
}
