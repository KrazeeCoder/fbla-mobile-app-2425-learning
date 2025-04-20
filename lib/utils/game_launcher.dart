import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../coach_marks/showcase_provider.dart';
import '../minigames/racing_game.dart';
import '../minigames/cypher_game.dart';
import '../minigames/maze_game.dart';
import '../minigames/puzzle_game.dart';
import '../minigames/quiz_challenge_game.dart';
import '../minigames/word_scramble_game.dart';
import 'package:provider/provider.dart';
import '../widgets/subtopic_widget.dart';
import 'app_logger.dart';
import 'audio/audio_integration.dart';

/// Launches a random game from the available game list based on subject
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
  AppLogger.i("Launching Random Game");

  // Store a local reference to context to avoid BuildContext issues
  final BuildContext localContext = context;

  try {
    if (!localContext.mounted) {
      AppLogger.e("Context not mounted in launchRandomGame");
      return;
    }

    // Instead of creating all game instances upfront, just choose a game type first
    final gameTypes = [
      'RacingGame',
      'CypherUI',
      'QuizChallengeGame',
      'PuzzleScreen',
      'MazeGame',
    ];


    // Add word scramble game for specific subjects
    if (subject.toLowerCase() == "history" ||
        subject.toLowerCase() == "english") {
      gameTypes.add('WordScrambleGame');
    }

    // Shuffle and select just one game type
    gameTypes.shuffle();
    final selectedGameType = gameTypes.first;

    // Initialize only the selected game
    Widget gameWidget;

    switch (selectedGameType) {
      case 'RacingGame':
        gameWidget = RacingGame(
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
        );
        break;
      case 'CypherUI':
        gameWidget = CypherUI(
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
        );
        break;
      case 'QuizChallengeGame':
        gameWidget = QuizChallengeGame(
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
        );
        break;
      case 'PuzzleScreen':
        gameWidget = PuzzleScreen(
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
        );
        break;
      case 'WordScrambleGame':
        gameWidget = WordScrambleGame(
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
        );
        break;
      case 'MazeGame':
        gameWidget = MazeGame(
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
        );
        break;

      default:
        // Fallback to quiz game if something goes wrong
        gameWidget = QuizChallengeGame(
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
        );
    }

    // Play game start sound in parallel with navigation
    AudioIntegration.handleGameStart().catchError((e) {
      AppLogger.e("Error playing game start sound, continuing: $e");
    });

    // Navigate to the selected game
    Navigator.pushReplacement(
      localContext,
      MaterialPageRoute(
        builder: (context) => gameWidget,
        settings: RouteSettings(name: 'Game_$selectedGameType'),
      ),
    );
  } catch (e) {
    AppLogger.e("Error launching game: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error launching game: $e")),
      );
    }
  }
}

/// Launches the puzzle game (used for showcase/tutorial flow)
Future<void> launchMazeGame({
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
  AppLogger.i("Launching Puzzle Game");

  // Store a local reference to context to avoid BuildContext issues
  final BuildContext localContext = context;

  // Play game start sound
  try {
    await AudioIntegration.handleGameStart();
  } catch (e) {
    AppLogger.e("Error playing game start sound, continuing: $e");
    // Continue launching game even if sound fails
  }

  try {
    if (!localContext.mounted) {
      AppLogger.e("Context not mounted in launchMazeGame");
      return;
    }

    Navigator.pushReplacement(
      localContext,
      MaterialPageRoute(
        builder: (context) => ShowCaseWidget(
          builder: (context) => MazeGame(
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
        ),
        settings: const RouteSettings(name: 'Game_MazeGame'),
      ),
    );
  } catch (e) {
    AppLogger.e("Error launching puzzle game: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error launching puzzle game: $e")),
      );
    }
  }
}

/// Helper function to navigate to the next lesson
Future<void> navigateToNextLesson({
  required BuildContext context,
  required String subject,
  required int grade,
  required int unitId,
  required String unitTitle,
  required String nextSubtopicId,
  required String nextSubtopicTitle,
  required String nextReadingContent,
  required String userId,
}) async {
  if (nextSubtopicId.isEmpty) {
    AppLogger.w("No next subtopic to navigate to");
    return;
  }

  // Store a local reference to context to avoid BuildContext issues
  final BuildContext localContext = context;

  try {
    // Play subtopic completion sound
    try {
      await AudioIntegration.handleSubtopicComplete();
    } catch (e) {
      AppLogger.e("Error playing subtopic completion sound, continuing: $e");
      // Continue navigation even if sound fails
    }

    // Check if widget is still valid
    if (!localContext.mounted) {
      AppLogger.w("Context is no longer valid for navigation");
      return;
    }

    // Verify that the required content is available
    if (nextReadingContent.isEmpty) {
      AppLogger.e("Next reading content is empty, cannot navigate");
      return;
    }

    // Always use direct navigation to the next lesson
    Navigator.pushReplacement(
      localContext,
      MaterialPageRoute(
        builder: (context) => ShowCaseWidget(
          builder: (context) => SubtopicPage(
            subtopic: nextSubtopicTitle,
            subtopicId: nextSubtopicId,
            readingTitle: nextSubtopicTitle,
            readingContent: nextReadingContent,
            isCompleted: false,
            subject: subject,
            grade: grade,
            unitId: unitId,
            unitTitle: unitTitle,
            userId: userId,
            lastSubtopicofUnit: false,
            lastSubtopicofGrade: false,
            lastSubtopicofSubject: false,
          ),
        ),
        settings: const RouteSettings(name: 'NextLesson'),
      ),
    );
  } catch (e) {
    AppLogger.e("Error navigating to next lesson: $e");

    // Only show SnackBar if context is still valid
    if (localContext.mounted) {
      ScaffoldMessenger.of(localContext).showSnackBar(
        const SnackBar(
            content: Text("Unable to load next lesson. Please try again.")),
      );
    }
  }
}

/// Launches a random game from the available game list based on subject
Future<void> launchRandomGameFromPathway({
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
  AppLogger.i("Launching Random Game");

  // Store a local reference to context to avoid BuildContext issues
  final BuildContext localContext = context;

  try {
    if (!localContext.mounted) {
      AppLogger.e("Context not mounted in launchRandomGame");
      return;
    }

    // Instead of creating all game instances upfront, just choose a game type first
    final gameTypes = [
      'RacingGame',
      'CypherUI',
      'QuizChallengeGame',
      'PuzzleScreen',
    ];

    // Add word scramble game for specific subjects
    if (subject.toLowerCase() == "history" ||
        subject.toLowerCase() == "english") {
      gameTypes.add('WordScrambleGame');
    }

    // Shuffle and select just one game type
    gameTypes.shuffle();
    final selectedGameType = gameTypes.first;

    // Initialize only the selected game
    Widget gameWidget;

    switch (selectedGameType) {
      case 'RacingGame':
        gameWidget = RacingGame(
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
        );
        break;
      case 'CypherUI':
        gameWidget = CypherUI(
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
        );
        break;
      case 'QuizChallengeGame':
        gameWidget = QuizChallengeGame(
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
        );
        break;
      case 'PuzzleScreen':
        gameWidget = PuzzleScreen(
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
        );
        break;
      case 'WordScrambleGame':
        gameWidget = WordScrambleGame(
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
        );
        break;
      default:
        // Fallback to quiz game if something goes wrong
        gameWidget = QuizChallengeGame(
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
        );
    }

    // Play game start sound in parallel with navigation
    AudioIntegration.handleGameStart().catchError((e) {
      AppLogger.e("Error playing game start sound, continuing: $e");
    });

    // Use push for pathway navigation to allow going back
    Navigator.push(
      localContext,
      MaterialPageRoute(
        builder: (context) => gameWidget,
        settings: RouteSettings(name: 'Game_$selectedGameType'),
      ),
    );
  } catch (e) {
    AppLogger.e("Error launching game: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error launching game: $e")),
      );
    }
  }
}
