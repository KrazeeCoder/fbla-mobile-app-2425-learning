import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../minigames/racing_game.dart';
import '../pages/subtopic_page.dart';
import 'app_logger.dart';
import '../managers/audio/audio_integration.dart';

/// Launches only the Racing Game
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
  AppLogger.i("Launching Racing Game");

  final BuildContext localContext = context;

  try {
    if (!localContext.mounted) {
      AppLogger.e("Context not mounted in launchRandomGame");
      return;
    }

    final Widget gameWidget = RacingGame(
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

    AudioIntegration.handleGameStart().catchError((e) {
      AppLogger.e("Error playing game start sound, continuing: $e");
    });

    Navigator.pushReplacement(
      localContext,
      MaterialPageRoute(
        builder: (context) => gameWidget,
        settings: const RouteSettings(name: 'Game_RacingGame'),
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

/// Navigate to the next lesson
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

  final BuildContext localContext = context;

  try {
    try {
      await AudioIntegration.handleSubtopicComplete();
    } catch (e) {
      AppLogger.e("Error playing subtopic completion sound, continuing: $e");
    }

    if (!localContext.mounted) {
      AppLogger.w("Context is no longer valid for navigation");
      return;
    }

    if (nextReadingContent.isEmpty) {
      AppLogger.e("Next reading content is empty, cannot navigate");
      return;
    }

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

    if (localContext.mounted) {
      ScaffoldMessenger.of(localContext).showSnackBar(
        const SnackBar(
            content: Text("Unable to load next lesson. Please try again.")),
      );
    }
  }
}

/// Launches only Racing Game from the pathway
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
  AppLogger.i("Launching Racing Game");

  final BuildContext localContext = context;

  try {
    if (!localContext.mounted) {
      AppLogger.e("Context not mounted in launchRandomGame");
      return;
    }

    final Widget gameWidget = RacingGame(
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

    AudioIntegration.handleGameStart().catchError((e) {
      AppLogger.e("Error playing game start sound, continuing: $e");
    });

    Navigator.push(
      localContext,
      MaterialPageRoute(
        builder: (context) => gameWidget,
        settings: const RouteSettings(name: 'Game_RacingGame'),
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
