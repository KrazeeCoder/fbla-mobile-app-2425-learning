import 'package:flutter/material.dart';

/// Class to hold all coach mark keys used throughout the app
class ShowcaseKeys {
  // Home Screen Keys
  static final GlobalKey helpIconKey = GlobalKey(debugLabel: 'help_icon_key');
  static final GlobalKey pickUpLessonKey =
      GlobalKey(debugLabel: 'pick_up_lesson_key');
  static final GlobalKey audioIconKey = GlobalKey(debugLabel: 'audio_icon_key');

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
  static final GlobalKey gameContentKey =
      GlobalKey(debugLabel: 'game_content_key');
  static final GlobalKey backFromGameKey =
      GlobalKey(debugLabel: 'back_from_game_key');

  // progress screen keys
  static final GlobalKey progressStatsKey =
      GlobalKey(debugLabel: 'progress_stats_key');
  static final GlobalKey progressLeaderboardKey =
      GlobalKey(debugLabel: 'progress_leaderboard_key');
  static final GlobalKey progressRecentActivityKey =
      GlobalKey(debugLabel: 'progress_recent_activity_key');

  // settings screen keys
  static final GlobalKey settingsScreenKey =
      GlobalKey(debugLabel: 'settings_screen_key');

  static List<GlobalKey> getHomeShowcaseKeys() => [
        helpIconKey, // help icon at top of customappbar
        pickUpLessonKey, // "recent lessons" widget at bottom of home screen
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
        gameContentKey, // game content in practice screen
        backFromGameKey, // back from game button in practice screen
      ];

  static List<GlobalKey> getPathwayToProgressScreenShowcaseKeys() => [
        progressNavKey, // progress nav key in main screen
      ];

  static List<GlobalKey> getProgressScreenShowcaseKeys() => [
        progressStatsKey, // progress stats in progress screen
        progressLeaderboardKey, // progress leaderboard in progress screen
        progressRecentActivityKey, // progress recent activity in progress screen
        settingsNavKey, // settings nav key to go to settings screen
      ];

  static List<GlobalKey> getSettingsScreenShowcaseKeys() => [
        settingsScreenKey, // settings screen key to go to settings screen
        homeNavKey, // home nav key to go back to home screen
      ];
}
