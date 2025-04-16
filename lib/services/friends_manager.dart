import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_logger.dart';

class FriendsManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user's friends list
  static Future<List<String>> getFriendsList() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final data = userDoc.data() ?? {};
      return List<String>.from(data['friends'] ?? []);
    } catch (e) {
      AppLogger.e('Error getting friends list', error: e);
      return [];
    }
  }

  /// Add a friend by their UID
  static Future<bool> addFriend(String friendUid) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if friend exists
      final friendDoc =
          await _firestore.collection('users').doc(friendUid).get();
      if (!friendDoc.exists) {
        AppLogger.e('Friend user does not exist');
        return false;
      }

      // Check if already friends
      final currentFriends = await getFriendsList();
      if (currentFriends.contains(friendUid)) {
        AppLogger.e('Already friends with this user');
        return false;
      }

      // Add friend to current user's friends list
      await _firestore.collection('users').doc(user.uid).update({
        'friends': FieldValue.arrayUnion([friendUid])
      });

      // Add current user to friend's friends list (reciprocal friendship)
      await _firestore.collection('users').doc(friendUid).update({
        'friends': FieldValue.arrayUnion([user.uid])
      });

      return true;
    } catch (e) {
      AppLogger.e('Error adding friend', error: e);
      return false;
    }
  }

  /// Remove a friend by their UID
  static Future<bool> removeFriend(String friendUid) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Remove friend from current user's friends list
      await _firestore.collection('users').doc(user.uid).update({
        'friends': FieldValue.arrayRemove([friendUid])
      });

      // Remove current user from friend's friends list
      await _firestore.collection('users').doc(friendUid).update({
        'friends': FieldValue.arrayRemove([user.uid])
      });

      return true;
    } catch (e) {
      AppLogger.e('Error removing friend', error: e);
      return false;
    }
  }

  /// Get friend's basic info (username, XP, level)
  static Future<Map<String, dynamic>?> getFriendInfo(String friendUid) async {
    try {
      final friendDoc =
          await _firestore.collection('users').doc(friendUid).get();
      if (!friendDoc.exists) return null;

      final data = friendDoc.data() ?? {};
      return {
        'username': data['username'] ?? 'Friend',
        'currentXP': data['currentXP'] ?? 0,
        'level': await calculateLevelFromXP(data['currentXP'] ?? 0),
      };
    } catch (e) {
      AppLogger.e('Error getting friend info', error: e);
      return null;
    }
  }

  /// Get all friends' info
  static Future<List<Map<String, dynamic>>> getAllFriendsInfo() async {
    try {
      final friendsList = await getFriendsList();
      if (friendsList.isEmpty) return [];

      final friendsDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendsList)
          .get();

      final List<Map<String, dynamic>> friendsInfo = [];
      for (var doc in friendsDocs.docs) {
        final data = doc.data();
        friendsInfo.add({
          'uid': doc.id,
          'username': data['username'] ?? 'Friend',
          'currentXP': data['currentXP'] ?? 0,
          'level': await calculateLevelFromXP(data['currentXP'] ?? 0),
        });
      }

      return friendsInfo;
    } catch (e) {
      AppLogger.e('Error getting all friends info', error: e);
      return [];
    }
  }

  /// Get friend's daily activity (subtopics completed today)
  static Future<int> getFriendDailyActivity(String friendUid) async {
    try {
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      final todayTimestamp = Timestamp.fromDate(today);
      final tomorrowTimestamp =
          Timestamp.fromDate(today.add(const Duration(days: 1)));

      final completionDoc =
          await _firestore.collection('user_completed').doc(friendUid).get();

      if (!completionDoc.exists) return 0;

      final data = completionDoc.data();
      final List<dynamic> completed = data?['completed'] ?? [];

      int count = 0;
      for (var item in completed) {
        if (item is Map<String, dynamic> &&
            item['datetime'] is Timestamp &&
            item['type'] == 'subtopic') {
          final Timestamp timestamp = item['datetime'];
          if (timestamp.compareTo(todayTimestamp) >= 0 &&
              timestamp.compareTo(tomorrowTimestamp) < 0) {
            count++;
          }
        }
      }

      return count;
    } catch (e) {
      AppLogger.e('Error getting friend daily activity', error: e);
      return 0;
    }
  }

  /// Calculate level from XP
  static Future<int> calculateLevelFromXP(int xp) async {
    try {
      final levelQuery = await _firestore
          .collection('level_master')
          .where('minimum_point', isLessThanOrEqualTo: xp)
          .where('maximum_point', isGreaterThanOrEqualTo: xp)
          .limit(1)
          .get();

      if (levelQuery.docs.isNotEmpty) {
        return levelQuery.docs.first.data()['Level'] ?? 1;
      }
      return 1;
    } catch (e) {
      AppLogger.e('Error calculating level from XP', error: e);
      return 1;
    }
  }

  /// Search for users by username
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // Get current friends list to exclude them from search
      final currentFriends = await getFriendsList();

      // Search for users with matching username
      final usersQuery = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final List<Map<String, dynamic>> results = [];
      for (var doc in usersQuery.docs) {
        // Skip current user and friends
        if (doc.id == user.uid || currentFriends.contains(doc.id)) continue;

        final data = doc.data();
        results.add({
          'uid': doc.id,
          'username': data['username'] ?? 'User',
          'currentXP': data['currentXP'] ?? 0,
          'level': await calculateLevelFromXP(data['currentXP'] ?? 0),
        });
      }

      return results;
    } catch (e) {
      AppLogger.e('Error searching users', error: e);
      return [];
    }
  }
}
