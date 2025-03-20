import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **Registers a new user with email and password**
  Future<String?> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int age,
  }) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) return "Invalid registration information";

      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'currentLevel': 0,
        'currentXP': 0,
        'settings': {
          'fontSize': 14,
          'profilePic': "",
          'stayOnTrack': false,
        }
      });

      // Store subtopicsCompleted with timestamps
      await _firestore.collection('user_subtopics').doc(user.uid).set({
        'subtopicsCompleted': [],
      });

      return "Success";
    } catch (e) {
      print("❌ Error registering user: $e");
      return e.toString();
    }
  }

  /// **Adds a completed subtopic with a timestamp**
  Future<void> completeSubtopic(int subtopicId) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('user_subtopics').doc(user.uid).update({
        'subtopicsCompleted': FieldValue.arrayUnion([
          {'subtopicId': subtopicId, 'timestamp': Timestamp.now()}
        ])
      });
      print("✅ Subtopic $subtopicId marked as completed.");
    } catch (e) {
      print("❌ Error updating subtopics: $e");
    }
  }
  /// **Logs in a user with email and password**
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      print("❌ Login Error: $e");
      return null;
    }
  }

  /// **Checks if a user exists in Firestore by email**
  Future<bool> userExists(String email) async {
    try {
      QuerySnapshot result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      print("❌ Error checking user existence: $e");
      return false;
    }
  }

  /// **Registers a new LinkedIn user in Firestore**
  Future<void> registerUserFromLinkedIn({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    required String? profilePic,
  }) async {
    try {
      // Save LinkedIn user data with structured settings
    await _firestore.collection('users').doc(userId).set({
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'age': 0, // ✅ Default age set to 0
      'currentLevel': 0,
      'currentXP': 0,
      'settings': {  // ✅ Properly grouping settings
        'fontSize': 14,
        'profilePic': profilePic ?? "",
        'stayOnTrack': false,
      }
    }, SetOptions(merge: true)); // ✅ Ensures existing data is not overwritten


      // Create `user_subtopics` collection
      await _firestore.collection('user_subtopics').doc(userId).set({
        'subtopicsCompleted': [],
      });

      print("✅ New LinkedIn user added to Firestore!");
    } catch (e) {
      print("❌ Error registering LinkedIn user: $e");
    }
  }
}


