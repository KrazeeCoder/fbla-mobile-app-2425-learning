import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils/app_logger.dart';
import 'services/progress_service.dart';

class XPManager extends ChangeNotifier {
  int _currentXP = 0;
  int _currentLevel = 1;
  bool _isLoading = true;
  String? _userId;

  // Expose values for UI
  int get currentXP => _currentXP;
  int get currentLevel => _currentLevel;
  bool get isLoading => _isLoading;

  // Progress information for level progress bar
  int _minXPForCurrentLevel = 0;
  int _maxXPForCurrentLevel = 100;

  int get minXPForCurrentLevel => _minXPForCurrentLevel;
  int get maxXPForCurrentLevel => _maxXPForCurrentLevel;

  // Calculate percentage progress to next level (0.0 to 1.0)
  double get levelProgress {
    if (_maxXPForCurrentLevel == _minXPForCurrentLevel) return 1.0;
    return (_currentXP - _minXPForCurrentLevel) /
        (_maxXPForCurrentLevel - _minXPForCurrentLevel);
  }

  XPManager() {
    _initUser();
  }

  // Initialize with current user data
  Future<void> _initUser() async {
    _isLoading = true;
    notifyListeners();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;

      // Ensure the user document exists with XP data
      await _ensureUserDocumentExists(_userId!);

      // Then load the data
      await refreshXPAndLevel();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Ensures that a user document exists with XP data
  Future<void> _ensureUserDocumentExists(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists || userDoc.data()?['currentXP'] == null) {
        // Create or update user document with default XP values
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'currentXP': 0,
          'created': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        AppLogger.i('Created new user XP document for user: $userId');
      }
    } catch (e) {
      AppLogger.e('Error ensuring user document exists', error: e);
    }
  }

  // Refresh XP and level data from Firestore
  Future<bool> refreshXPAndLevel() async {
    if (_userId == null) return false;

    try {
      AppLogger.d("Refreshing XP and level data");

      // First fetch user data from the users collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      // Get the current XP from the user document
      final userData = userDoc.data() ?? {};
      final int currentUserXP = (userData['currentXP'] as num?)?.toInt() ?? 0;

      // Calculate the level based on XP
      int newLevel = 1; // Default level

      // Find the appropriate level based on the user's XP
      final levelQuery = await FirebaseFirestore.instance
          .collection('level_master')
          .where('minimum_point', isLessThanOrEqualTo: currentUserXP)
          .where('maximum_point', isGreaterThanOrEqualTo: currentUserXP)
          .limit(1)
          .get();

      if (levelQuery.docs.isNotEmpty) {
        newLevel = levelQuery.docs.first.data()['Level'] ?? 1;
      }

      // Fetch level boundaries from Firestore
      await _fetchLevelBoundaries(newLevel);

      // Check if level changed
      bool leveledUp = (newLevel > _currentLevel) && (_currentLevel > 0);

      // Update current values
      _currentXP = currentUserXP;
      _currentLevel = newLevel;

      AppLogger.d("XP updated: Level $newLevel, XP $currentUserXP");

      notifyListeners();

      // Return info about whether leveled up
      return leveledUp;
    } catch (e) {
      AppLogger.e('Error refreshing XP data', error: e);
      return false;
    }
  }

  // Fetch min and max XP values for current level from Firestore
  Future<void> _fetchLevelBoundaries(int level) async {
    try {
      final levelDoc = await FirebaseFirestore.instance
          .collection('level_master')
          .where('Level', isEqualTo: level)
          .limit(1)
          .get();

      if (levelDoc.docs.isNotEmpty) {
        _minXPForCurrentLevel =
            levelDoc.docs.first.data()['minimum_point'] as int;
        _maxXPForCurrentLevel =
            levelDoc.docs.first.data()['maximum_point'] as int;
      }
    } catch (e) {
      AppLogger.e('Error fetching level boundaries', error: e);
    }
  }

  // Add XP and check for level up
  Future<bool> addXP(int xpAmount, {Function? onLevelUp}) async {
    if (_userId == null) return false;

    AppLogger.d("Adding $xpAmount XP to user $_userId");

    // Store old level for comparison
    int oldLevel = _currentLevel;

    // Add XP directly to users collection
    try {
      await FirebaseFirestore.instance.collection('users').doc(_userId).set({
        'currentXP': FieldValue.increment(xpAmount),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update local value first
      _currentXP += xpAmount;

      // Refresh data to get new values and level
      bool leveledUp = await refreshXPAndLevel();

      // If level increased, trigger level up callback
      if (leveledUp && onLevelUp != null) {
        onLevelUp(_currentLevel);
      }

      return leveledUp;
    } catch (e) {
      AppLogger.e('Error adding XP', error: e);
      return false;
    }
  }

  // Get next level details
  Future<Map<String, dynamic>> getNextLevelDetails() async {
    try {
      final nextLevelDoc = await FirebaseFirestore.instance
          .collection('level_master')
          .where('Level', isEqualTo: _currentLevel + 1)
          .limit(1)
          .get();

      if (nextLevelDoc.docs.isNotEmpty) {
        return nextLevelDoc.docs.first.data();
      }
      return {};
    } catch (e) {
      AppLogger.e('Error fetching next level details', error: e);
      return {};
    }
  }

  // Show level up animation/screen
  void showLevelUpAnimation(BuildContext context, int newLevel) {
    // Get next level details for display
    getNextLevelDetails().then((nextLevelDetails) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade300,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "LEVEL UP!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "You've reached Level $newLevel",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Display any level perks or benefits here
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "New achievements unlocked!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
