import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// **Gets the current user ID securely**
  String? get _userId => _auth.currentUser?.uid;

  /// **Fetch completed subtopics from `user_subtopics` collection**
  Future<List<String>?> getCompletedSubtopics() async {
    if (_userId == null) return null;

    try {
      DocumentSnapshot docSnapshot =
      await _firestore.collection('user_subtopics').doc(_userId).get();

      if (docSnapshot.exists) {
        return List<String>.from(docSnapshot.get('subtopicsCompleted'));
      }
      return [];
    } catch (e) {
      print("Error fetching completed subtopics: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getCompleted() async {
    if (_userId == null) return null;

    try {
      DocumentSnapshot docSnapshot =
      await _firestore.collection('user_completed').doc(_userId).get();

      if (docSnapshot.exists) {
        return List<Map<String, dynamic>>.from(docSnapshot.get('completed'));
      }
      return [];
    } catch (e) {
      print("Error fetching completed subtopics: $e");
      return null;
    }
  }



  /// **Marks a subtopic as completed in `user_subtopics` collection**
  Future<String?> completeSubtopic(String subtopicId) async {
    if (_userId == null) return "User not logged in";

    try {
      await _firestore.collection('user_subtopics').doc(_userId).update({
        'subtopicsCompleted': FieldValue.arrayUnion([subtopicId]),
      });
      return "Success";
    } catch (e) {
      print("Error completing subtopic: $e");
      return e.toString();
    }
  }

  Future<String> completeStep(String id, String type, DateTime datetime) async {
    if (_userId == null) return "User not logged in";
    final docRef = FirebaseFirestore.instance.collection('user_completed').doc(_userId);

    try {
      // Create the new map to add
      Map<String, dynamic> newEntry = {
        'datetime': datetime,
        'id': id,
        'type': type,
      };

      // Update the document by appending the new map to the "completed" list
      await docRef.update({
        'completed': FieldValue.arrayUnion([newEntry]),
      });

      return "Success";
    } catch (e) {
      return e.toString();
    }

  }

  /// **Increases XP in `users` collection**
  Future<String?> gainXP(int xpGained) async {
    if (_userId == null) return "User not logged in";

    try {
      await _firestore.collection('users').doc(_userId).update({
        'currentXP': FieldValue.increment(xpGained),
      });
      return "XP updated successfully";
    } catch (e) {
      print("Error updating XP: $e");
      return e.toString();
    }
  }

  /// **Retrieves the user's current streak days**
  Future<int?> getStreak() async {
    if (_userId == null) return null;

    try {
      DocumentSnapshot docSnapshot =
      await _firestore.collection('users').doc(_userId).get();

      if (docSnapshot.exists) {
        return docSnapshot.get('streakDays') ?? 0;
      }
      return 0;
    } catch (e) {
      print("Error fetching streak: $e");
      return null;
    }
  }

  /// **Retrieves the user's current streak days**
  Future<int?> getLevel() async {
    if (_userId == null) return null;

    try {
      DocumentSnapshot docSnapshot =
      await _firestore.collection('users').doc(_userId).get();

      if (docSnapshot.exists) {
        return docSnapshot.get('currentLevel') ?? 0;
      }
      return 0;
    } catch (e) {
      print("Error fetching streak: $e");
      return null;
    }
  }
}
