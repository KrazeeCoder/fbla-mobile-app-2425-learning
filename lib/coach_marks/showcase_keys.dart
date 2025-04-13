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
  static final GlobalKey recentLessonItemKey =
      GlobalKey(debugLabel: 'recent_lesson_item_key');

  // Progress Screen Keys
  static final GlobalKey completedTabKey =
      GlobalKey(debugLabel: 'completed_tab_key');

  // Pathway Screen Keys
  static final GlobalKey pathwayLessonKey =
      GlobalKey(debugLabel: 'pathway_lesson_key');
  static final GlobalKey pathwayBackButtonKey =
      GlobalKey(debugLabel: 'pathway_back_button_key');
  static final GlobalKey subtopicKey = GlobalKey(debugLabel: 'subtopic_key');
  static final GlobalKey subtopicBackButtonKey =
      GlobalKey(debugLabel: 'subtopic_back_button_key');

  // Settings Screen Keys
  static final GlobalKey settingsPageKey =
      GlobalKey(debugLabel: 'settings_page_key');
  static final GlobalKey homeNavKey = GlobalKey(debugLabel: 'home_nav_key');

  // Get all keys in the order they should be shown
  static List<GlobalKey> getInitialShowcaseKeys() => [
        // Home screen elements
        helpIconKey,
        pickUpLessonKey,

        // Learn screen elements
        learnNavKey,
        recentLessonItemKey,
        pathwayLessonKey,
        subtopicKey,
        subtopicBackButtonKey,
        pathwayBackButtonKey,
        chooseLessonTabKey,
        selectSubjectKey,

        // Progress screen elements
        progressNavKey,
        completedTabKey,

        // Settings screen elements
        settingsPageKey,
        homeNavKey,
      ];
}
