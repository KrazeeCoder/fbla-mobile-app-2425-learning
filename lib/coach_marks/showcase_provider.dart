import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';
import 'showcase_keys.dart';

class ShowcaseService extends ChangeNotifier {
  bool _hasCompletedInitialShowcase = false;
  bool _isShowcaseActive = false;

  bool get hasCompletedInitialShowcase => _hasCompletedInitialShowcase;
  bool get isShowcaseActive => _isShowcaseActive;

  // Key for shared preferences
  static const String _showcaseCompletedKey = 'showcase_completed';

  // Initialize the showcase service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _hasCompletedInitialShowcase =
        prefs.getBool(_showcaseCompletedKey) ?? false;
    notifyListeners();
  }

  // Mark showcase as completed
  Future<void> markShowcaseComplete() async {
    _hasCompletedInitialShowcase = true;
    _isShowcaseActive = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showcaseCompletedKey, true);
    notifyListeners();
  }

  // Reset showcase (for testing)
  Future<void> resetShowcase() async {
    _hasCompletedInitialShowcase = false;
    _isShowcaseActive = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showcaseCompletedKey, false);
    notifyListeners();
  }

  // Start a showcase with custom keys
  static void startCustomShowcase(BuildContext context, List<GlobalKey> keys) {
    if (keys.isEmpty) return;

    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ShowCaseWidgetState? showcaseWidget = ShowCaseWidget.of(context);
        if (showcaseWidget != null) {
          showcaseWidget.startShowCase(keys);
        }
      });
    } catch (e) {
      debugPrint('Error starting custom showcase: $e');
    }
  }

  // Start Home screen showcase
  void startHomeScreenShowcase(BuildContext context) {
    _isShowcaseActive = true;
    notifyListeners();
    startCustomShowcase(context, ShowcaseKeys.getHomeShowcaseKeys());
  }

  // Start Learn screen showcase
  void startLearnScreenShowcase(BuildContext context) {
    _isShowcaseActive = true;
    notifyListeners();
    startCustomShowcase(context, ShowcaseKeys.getLearnTabShowcaseKeys());
    AppLogger.i("Starting Learn screen showcase");
  }

  // Start Pathway step showcase
  void startPathwayScreenShowcase(BuildContext context) {
    _isShowcaseActive = true;
    notifyListeners();
    startCustomShowcase(context, ShowcaseKeys.getPathwayScreenShowcaseKeys());
  }

  // Start Subtopic screen showcase
  void startSubtopicScreenShowcase(BuildContext context) {
    _isShowcaseActive = true;
    notifyListeners();
    startCustomShowcase(context, ShowcaseKeys.getSubtopicScreenShowcaseKeys());
  }

  // Start Game screen showcase
  void startGameScreenShowcase(BuildContext context) {
    _isShowcaseActive = true;
    notifyListeners();
    startCustomShowcase(context, ShowcaseKeys.getGameScreenShowcaseKeys());
  }
}
