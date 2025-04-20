import 'package:flutter/material.dart';
import 'audio_integration.dart';

/// This is an example class that demonstrates how to use audio
/// within a game or quiz component of the app.
class GameAudioExample {
  /// Call this when the game/quiz starts
  static void onGameStart() {
    AudioIntegration.handleGameStart();
  }

  /// Call this when the user answers a question correctly
  static void onCorrectAnswer(BuildContext context) {
    // Play haptic feedback for correct answer
    AudioIntegration.handleButtonPress();

    // Visual feedback could be shown here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Correct!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// Call this when the user completes a level or quiz
  static void onGameCompletion({
    required BuildContext context,
    required int score,
    required int totalQuestions,
    required VoidCallback onContinue,
  }) {
    // Play completion sound
    AudioIntegration.handleGameComplete();

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Level Complete!'),
        content: Text('You scored $score out of $totalQuestions'),
        actions: [
          TextButton(
            onPressed: () {
              // Use haptic feedback for button press
              AudioIntegration.handleButtonPress();
              Navigator.of(context).pop();
              onContinue();
            },
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }

  /// Call this when the user completes a subtopic
  static void onSubtopicComplete(BuildContext context) {
    // Play subtopic completion sound
    AudioIntegration.handleSubtopicComplete();

    // Example visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subtopic Completed!'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
