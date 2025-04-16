import 'package:flutter/material.dart';

/// Class to hold all coach mark keys used throughout the app
class ShowcaseKeys {
  // Home Screen Keys
  static final GlobalKey helpIconKey = GlobalKey(debugLabel: 'help_icon_key');
  static final GlobalKey pickUpLessonKey =
      GlobalKey(debugLabel: 'pick_up_lesson_key');

  // Navigation Keys
  static final GlobalKey learnNavKey = GlobalKey(debugLabel: 'learn_nav_key');
  static final GlobalKey progressNavKey =
      GlobalKey(debugLabel: 'progress_nav_key');
  static final GlobalKey settingsNavKey =
      GlobalKey(debugLabel: 'settings_nav_key');

  // Learn Screen Keys
  static final GlobalKey chooseLessonTabKey =
      GlobalKey(debugLabel: 'choose_lesson_tab_key');
  static final GlobalKey selectSubjectKey =
      GlobalKey(debugLabel: 'select_subject_key');
  static final GlobalKey recentLessonTabKey =
      GlobalKey(debugLabel: 'recent_lesson_tab_key');

  // Progress Screen Keys
  static final GlobalKey completedTabKey =
      GlobalKey(debugLabel: 'completed_tab_key');

  // Pathway Screen Keys
  static final GlobalKey pathwayBackButtonKey =
      GlobalKey(debugLabel: 'pathway_back_button_key');
  static final GlobalKey subtopicKey = GlobalKey(debugLabel: 'subtopic_key');
  static final GlobalKey subtopicBackButtonKey =
      GlobalKey(debugLabel: 'subtopic_back_button_key');

  // Settings Screen Keys
  static final GlobalKey homeNavKey = GlobalKey(debugLabel: 'home_nav_key');

  // Get all keys in the order they should be shown
  static List<GlobalKey> getInitialShowcaseKeys() => [
        // Home screen elements
        helpIconKey, // help icon at top of customappbar
        pickUpLessonKey, // "recetn lessons" widget at bottom of home screen

        // Learn screen elements
        learnNavKey, // learn tab at bottom of home screen
        recentLessonTabKey, // first recent lesson item in learn screen under recent lesons tab that navigates to pathway
        subtopicKey, // first subtopic item in pathway screen
        subtopicBackButtonKey, // back button in subtopic screen
        pathwayBackButtonKey, // back button in pathway screen
        chooseLessonTabKey, // choose lesson tab in learn screen
        selectSubjectKey, // select subject dropdown in learn screen

        // Progress screen elements
        progressNavKey, // progress tab at bottom of home screen
        completedTabKey, // completed tab in progress screen

        // Settings screen elements
        settingsNavKey, // settings page at bottom of home screen
        homeNavKey, // home tab at bottom of home screen
      ];

  static List<GlobalKey> getFirstShowcaseKeys() => [
        helpIconKey, // help icon at top of customappbar
        pickUpLessonKey, // "recetn lessons" widget at bottom of home screen
        learnNavKey, // learn tab at bottom of home screen
      ];

  static List<GlobalKey> getSecondShowcaseKeys() => [
        recentLessonTabKey, // first recent lesson item in learn screen under recent lesons tab that navigates to pathway
        chooseLessonTabKey, // choose lesson tab in learn screen
      ];

  static List<GlobalKey> getThirdShowcaseKeys() => [
        subtopicKey, // first subtopic item in pathway screen
        subtopicBackButtonKey, // back button in subtopic screen
      ];

  static List<GlobalKey> getFourthShowcaseKeys() => [
        pathwayBackButtonKey, // back button in pathway screen
        progressNavKey, // progress tab at bottom of home screen
      ];

  static List<GlobalKey> getFifthShowcaseKeys() => [
        completedTabKey, // completed tab in progress screen
        settingsNavKey, // settings page at bottom of home screen
        homeNavKey, // home tab at bottom of home screen
      ];
}
