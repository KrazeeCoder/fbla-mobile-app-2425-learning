import 'package:flutter/material.dart';
import 'package:fbla_mobile_2425_learning_app/widgets/earth_unlock_animation.dart';
import 'audio_manager.dart';
import 'audio_assets.dart';
import '../app_logger.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

/// This utility class demonstrates how to integrate the AudioManager
/// with different parts of the app.
class AudioIntegration {
  // Private constructor to prevent instantiation
  AudioIntegration._();

  // Track initialization state
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  // Set of verified assets to avoid checking the same asset multiple times
  static final Set<String> _verifiedAssets = {};

  /// Initializes the audio system, should be called from main.dart
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Verify that the main audio assets exist before attempting initialization
    try {
      // Pre-verify critical audio assets
      final assetResults = await Future.wait([
        _verifyAsset(AudioAssets.backgroundMusic),
        _verifyAsset(AudioAssets.levelComplete),
        _verifyAsset(AudioAssets.gameComplete),
        _verifyAsset(AudioAssets.gameStart),
      ], eagerError: false)
          .timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          AppLogger.w("Asset verification timed out");
          return [false, false, false, false];
        },
      );

      final bool assetsVerified = assetResults.any((result) => result);

      if (!assetsVerified) {
        AppLogger.w("No audio assets could be verified");
        _isInitialized = false;
        return;
      }

      // Initialize audio manager
      await AudioManager().initialize();

      // Only start the background music if initialization was successful
      if (AudioManager().isInitialized) {
        AppLogger.i("Audio system initialized, starting background music");
        await AudioManager().playBackgroundMusic();
      } else {
        print("failed");
      }

      _isInitialized = AudioManager().isInitialized;

      if (_isInitialized) {
        AppLogger.i("Audio system initialized successfully");
      } else {
        AppLogger.w("Audio system not fully initialized");
      }
    } catch (e) {
      // Log error but don't crash the app
      AppLogger.e("Error initializing audio system: $e");
      _isInitialized = false;
    }
  }

  /// Verifies that an asset exists and is accessible
  static Future<bool> _verifyAsset(String assetPath) async {
    // Skip check if already verified
    if (_verifiedAssets.contains(assetPath)) return true;

    try {
      // Try to load a small chunk of the asset to verify it exists
      await rootBundle.load(assetPath);

      // Add to verified assets set
      _verifiedAssets.add(assetPath);
      return true;
    } catch (e) {
      AppLogger.e("Error verifying asset $assetPath: $e");
      return false;
    }
  }

  /// Shows the earth unlock animation with appropriate sound effects
  static void showEarthUnlockWithSound(BuildContext context, int newLevel,
      String subject, String subtopic, int totalXP) {
    // The sound will be played in the EarthUnlockAnimation.show method
    EarthUnlockAnimation.show(context, newLevel, subject, subtopic, totalXP);
  }

  /// Use this for standard button presses - applies haptic feedback only
  static void handleButtonPress() {
    if (!_isInitialized) return;

    try {
      AudioManager().playButtonFeedback();
    } catch (e) {
      print("Error playing button feedback");
    }
  }

  /// Use this for navigating to a new screen - applies haptic feedback only
  static void handleNavigation() {
    if (!_isInitialized) return;

    try {
      AudioManager().playButtonFeedback();
    } catch (e) {
      print("Error playing navigation feedback");
    }
  }

  /// Use this when a level is completed
  static Future<void> handleLevelComplete() async {
    if (!_isInitialized) return;

    try {
      await AudioManager().playLevelCompleteSound();
    } catch (e) {
      print("Error playing level complete sound");
    }
  }

  /// Use this when a subtopic is completed
  static Future<void> handleSubtopicComplete() async {
    if (!_isInitialized) return;

    try {
      await AudioManager().playSubtopicCompleteSound();
    } catch (e) {
      print("Error playing subtopic complete sound");
    }
  }

  /// Use this when starting a game
  static Future<void> handleGameStart() async {
    if (!_isInitialized) return;

    try {
      await AudioManager().playGameStartSound();
    } catch (e) {
      print("Error playing game start sound");
    }
  }

  /// Use this when completing a game successfully
  static Future<void> handleGameComplete() async {
    if (!_isInitialized) return;

    try {
      await AudioManager().playGameCompleteSound();
    } catch (e) {
      print("Error playing game complete sound");
    }
  }
}
