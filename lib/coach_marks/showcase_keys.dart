import 'package:flutter/material.dart';

/// Class to hold all coach mark keys used throughout the app
class ShowcaseKeys {
  // Level bar key for homepage showcase
  static final GlobalKey levelBarKey = GlobalKey(debugLabel: 'level_bar_key');

  // Get all keys for initial coach marks
  static List<GlobalKey> getInitialShowcaseKeys() => [
        levelBarKey,
      ];
}
