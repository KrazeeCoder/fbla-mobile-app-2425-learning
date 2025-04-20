import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';
import 'showcase_keys.dart';

class ShowcaseService extends ChangeNotifier {
  bool _hasCompletedInitialShowcase = false;
  bool _isShowcaseActive = false;
  bool _completeTutorialPending =
      false; // Flag to indicate tutorial completion is pending

  bool get hasCompletedInitialShowcase => _hasCompletedInitialShowcase;
  bool get isShowcaseActive => _isShowcaseActive;
  bool get completeTutorialPending => _completeTutorialPending;

  // Key for shared preferences
  static const String _showcaseCompletedKey = 'showcase_completed';

  // Initialize the showcase service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _hasCompletedInitialShowcase = prefs.getBool(_showcaseCompletedKey) ?? true;
    _completeTutorialPending = false;
    notifyListeners();
  }

  // Mark showcase as completed
  Future<void> markShowcaseComplete() async {
    _hasCompletedInitialShowcase = true;
    _isShowcaseActive = false;
    _completeTutorialPending = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showcaseCompletedKey, true);
    notifyListeners();
    AppLogger.i("markshowcasecompleted called");
  }

  // Flag the tutorial as ready to be completed when user returns to home screen
  void markTutorialReadyToComplete() {
    if (!_hasCompletedInitialShowcase) {
      _completeTutorialPending = true;
      notifyListeners();
      AppLogger.i(
          "Tutorial marked as ready to complete when user returns to home");
    }
  }

  // Check and mark tutorial as complete if flagged and user is on home screen
  void checkAndCompleteTutorial() {
    if (_completeTutorialPending && !_hasCompletedInitialShowcase) {
      AppLogger.i(
          "Completing tutorial as user has returned to home after pathway to progress");
      markShowcaseComplete();
    }
  }

  // Reset showcase (for testing)
  Future<void> resetShowcase() async {
    _hasCompletedInitialShowcase = false;
    _isShowcaseActive = false;
    _completeTutorialPending = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showcaseCompletedKey, false);
    notifyListeners();
  }

  // Safely checks if a ShowCaseWidget is available in the context
  static bool _isShowCaseWidgetAvailable(BuildContext context) {
    try {
      // This will throw an exception if ShowCaseWidget is not in the context
      final showcaseState = ShowCaseWidget.of(context);
      return showcaseState != null;
    } catch (e) {
      AppLogger.e('ShowCaseWidget not found in context: $e');
      return false;
    }
  }

  // Safely start a showcase with error handling
  static void safeStartShowcase(BuildContext context, List<GlobalKey> keys) {
    if (keys.isEmpty) return;

    // Check if we have ShowCaseWidget in the context
    if (!_isShowCaseWidgetAvailable(context)) {
      AppLogger.w('ShowCaseWidget not available in context, showcase skipped');
      return;
    }

    try {
      // Delay to ensure widget tree is stable
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final showcaseWidget = ShowCaseWidget.of(context);
          showcaseWidget.startShowCase(keys);
          AppLogger.i('Showcase started successfully with ${keys.length} keys');
        } catch (e) {
          AppLogger.e('Error starting showcase in postFrameCallback: $e');
        }
      });
    } catch (e) {
      AppLogger.e('Error setting up showcase: $e');
    }
  }

  // Start a showcase with custom keys
  static void startCustomShowcase(BuildContext context, List<GlobalKey> keys) {
    safeStartShowcase(context, keys);
  }

  // Start Home screen showcase
  void startHomeScreenShowcase(BuildContext context) {
    _isShowcaseActive = true;
    notifyListeners();
    safeStartShowcase(context, ShowcaseKeys.getHomeShowcaseKeys());
    AppLogger.i("Home screen showcase requested");
  }

  // Start Learn screen showcase
  void startLearnScreenShowcase(BuildContext context) {
    _isShowcaseActive = true;
    notifyListeners();
    safeStartShowcase(context, ShowcaseKeys.getLearnTabShowcaseKeys());
    AppLogger.i("Learn screen showcase requested");
  }

  // Start Pathway step showcase
  void startPathwayScreenShowcase(BuildContext context) {
    _isShowcaseActive = true;
    notifyListeners();
    safeStartShowcase(context, ShowcaseKeys.getPathwayScreenShowcaseKeys());
    AppLogger.i("Pathway screen showcase requested");
  }

  // Start Subtopic screen showcase
  void startSubtopicScreenShowcase(BuildContext context) {
    _isShowcaseActive = true;
    notifyListeners();
    safeStartShowcase(context, ShowcaseKeys.getSubtopicScreenShowcaseKeys());
    AppLogger.i("Subtopic screen showcase requested");
  }

  // Start Game screen showcase
  void startGameScreenShowcase(BuildContext context) {
    _isShowcaseActive = true;
    notifyListeners();
    safeStartShowcase(context, ShowcaseKeys.getGameScreenShowcaseKeys());
    AppLogger.i("Game screen showcase requested");
  }

  // Start Pathway to Progress screen showcase
  void startPathwayToProgressScreenShowcase(BuildContext context) {
    _isShowcaseActive = true;
    notifyListeners();
    safeStartShowcase(
        context, ShowcaseKeys.getPathwayToProgressScreenShowcaseKeys());

    // This is the last step of the tutorial flow, so flag it as ready to complete
    // We don't mark it completed yet because we want it to be marked when the user returns to home
    markTutorialReadyToComplete();
    AppLogger.i(
        "Pathway to Progress showcase requested - final step of tutorial");
  }

  // Start Progress screen showcase
  void startProgressScreenShowcase(BuildContext context) {
    _isShowcaseActive = true;
    notifyListeners();
    safeStartShowcase(context, ShowcaseKeys.getProgressScreenShowcaseKeys());
    AppLogger.i("Progress screen showcase requested");
  }

  // Start Settings screen showcase
  void startSettingsScreenShowcase(BuildContext context) {
    _isShowcaseActive = true;
    notifyListeners();
    safeStartShowcase(context, ShowcaseKeys.getSettingsScreenShowcaseKeys());
    AppLogger.i("Settings screen showcase requested");
  }
}
