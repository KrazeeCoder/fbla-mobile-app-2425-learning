import 'package:flutter/material.dart';
import '../minigames/racing_game.dart';
import '../minigames/cypher_game.dart';
import '../minigames/maze_game.dart';
import '../minigames/puzzle_game.dart';
import '../minigames/quiz_challenge_game.dart';
import '../minigames/word_scramble_game.dart';

Future<void> launchRandomGame({
  required BuildContext context,
  required String subject,
  required int grade,
  required int unitId,
  required String unitTitle,
  required String subtopicId,
  required String subtopicTitle,
  required String nextSubtopicId,
  required String nextSubtopicTitle,
  required String nextReadingContent,
  required String userId,
}) async {
  final games = [
    RacingGame(
      subject: subject,
      grade: grade,
      unitId: unitId,
      unitTitle: unitTitle,
      subtopicId: subtopicId,
      subtopicTitle: subtopicTitle,
      nextSubtopicId: nextSubtopicId,
      nextSubtopicTitle: nextSubtopicTitle,
      nextReadingContent: nextReadingContent,
      userId: userId,
    ),
    CypherUI(
      subject: subject,
      grade: grade,
      unitId: unitId,
      unitTitle: unitTitle,
      subtopicId: subtopicId,
      subtopicTitle: subtopicTitle,
      nextSubtopicId: nextSubtopicId,
      nextSubtopicTitle: nextSubtopicTitle,
      nextReadingContent: nextReadingContent,
      userId: userId,
    ),
    MazeGame(
      subject: subject,
      grade: grade,
      unitId: unitId,
      unitTitle: unitTitle,
      subtopicId: subtopicId,
      subtopicTitle: subtopicTitle,
      nextSubtopicId: nextSubtopicId,
      nextSubtopicTitle: nextSubtopicTitle,
      nextReadingContent: nextReadingContent,
      userId: userId,
    ),
    PuzzleScreen(
      subject: subject,
      grade: grade,
      unitId: unitId,
      unitTitle: unitTitle,
      subtopicId: subtopicId,
      subtopicTitle: subtopicTitle,
      nextSubtopicId: nextSubtopicId,
      nextSubtopicTitle: nextSubtopicTitle,
      nextReadingContent: nextReadingContent,
      userId: userId,
    ),
    QuizChallengeGame(
      subject: subject,
      grade: grade,
      unitId: unitId,
      unitTitle: unitTitle,
      subtopicId: subtopicId,
      subtopicTitle: subtopicTitle,
      nextSubtopicId: nextSubtopicId,
      nextSubtopicTitle: nextSubtopicTitle,
      nextReadingContent: nextReadingContent,
      userId: userId,
    ),
  ];

  if (subject.toLowerCase() == "history" ||
      subject.toLowerCase() == "english") {
    games.add(
      WordScrambleGame(
        subject: subject,
        grade: grade,
        unitId: unitId,
        unitTitle: unitTitle,
        subtopicId: subtopicId,
        subtopicTitle: subtopicTitle,
        nextSubtopicId: nextSubtopicId,
        nextSubtopicTitle: nextSubtopicTitle,
        nextReadingContent: nextReadingContent,
        userId: userId,
      ),
    );
  }

  games.shuffle();
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => games.first),
  );
}
