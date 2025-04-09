import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowcaseProvider extends ChangeNotifier {
  bool _needsShowcase = false;
  bool _isInitialized = false;

  bool get needsShowcase => _needsShowcase;
  bool get isInitialized => _isInitialized;

  // Preference keys
  static const String _showcaseShownKey = 'showcase_shown';
  static const String _shouldShowTutorialKey = 'should_show_tutorial';

  // Initialize the provider by checking preferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _needsShowcase = prefs.getBool(_shouldShowTutorialKey) ?? false;
    _isInitialized = true;
    notifyListeners();
  }

  // Mark that showcase has been shown
  Future<void> markShowcaseComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showcaseShownKey, true);
    await prefs.setBool(_shouldShowTutorialKey, false);

    _needsShowcase = false;
    notifyListeners();
  }

  // Reset showcase to be shown again
  Future<void> resetShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showcaseShownKey, false);
    await prefs.setBool(_shouldShowTutorialKey, true);

    _needsShowcase = true;
    notifyListeners();
  }

  // Mark tutorial as needed for next load (e.g., after sign up)
  Future<void> markTutorialNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shouldShowTutorialKey, true);

    _needsShowcase = true;
    notifyListeners();
  }
}
