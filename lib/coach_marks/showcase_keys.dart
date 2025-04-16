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
  static final GlobalKey homeNavKey = GlobalKey(debugLabel: 'home_nav_key');

  // Learn Screen Keys
  static final GlobalKey chooseLessonTabKey =
      GlobalKey(debugLabel: 'choose_lesson_tab_key');

  static final GlobalKey recentLessonTabKey =
      GlobalKey(debugLabel: 'recent_lesson_tab_key');
  static final GlobalKey selectGradeKey =
      GlobalKey(debugLabel: 'select_grade_key');

  // pathway screen keys
  static final GlobalKey pathwayStepKey =
      GlobalKey(debugLabel: 'pathway_step_key');

  // subtopic screen keys
  static final GlobalKey contentKey = GlobalKey(debugLabel: 'content_key');
  static final GlobalKey chatIconKey = GlobalKey(debugLabel: 'chat_icon_key');
  static final GlobalKey continueToPracticeKey =
      GlobalKey(debugLabel: 'continue_to_practice_key');

  // practice screen keys
  static final GlobalKey backFromGameKey =
      GlobalKey(debugLabel: 'back_from_game_key');

  static List<GlobalKey> getHomeShowcaseKeys() => [
        helpIconKey, // help icon at top of customappbar
        pickUpLessonKey, // "recetn lessons" widget at bottom of home screen
        learnNavKey, // learn tab at bottom of home screen
      ];

  static List<GlobalKey> getLearnTabShowcaseKeys() => [
        recentLessonTabKey, // first recent lesson item in learn screen under recent lesons tab that navigates to pathway
        chooseLessonTabKey, // choose lesson tab in learn screen
        selectGradeKey, // select grade in learn screen
      ];

  static List<GlobalKey> getPathwayStepShowcaseKeys() => [
        selectGradeKey, // select grade in learn screen
      ];

  static List<GlobalKey> getPathwayScreenShowcaseKeys() => [
        pathwayStepKey, // pathway step in pathway screen
      ];

  static List<GlobalKey> getSubtopicScreenShowcaseKeys() => [
        contentKey, // content in subtopic screen
        chatIconKey, // chat icon in subtopic screen
        continueToPracticeKey, // continue to practice button in subtopic screen
      ];

  static List<GlobalKey> getGameScreenShowcaseKeys() => [
        backFromGameKey, // back from game button in practice screen
      ];
}
