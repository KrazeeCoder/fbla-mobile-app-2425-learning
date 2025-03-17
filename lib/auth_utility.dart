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
  }) async {
    try {
      // Create user with Firebase Auth
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) return "Invalid registration information";

      // Save user data in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'currentLevel': 0,
        'currentXP': 0,
      });

      // Create subtopicsCompleted in a separate collection
      await _firestore.collection('user_subtopics').doc(user.uid).set({
        'subtopicsCompleted': [],
      });

      // Add default settings in a subcollection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc(user.uid)
          .set({
        'fontSize': 14,
        'profilePic': 'default_pfp_202538.jpg',
        'stayOnTrack': false,
      });

      return "Success";
    } catch (e) {
      print("Error registering user: $e");
      return e.toString();
    }
  }

  /// **Logs in a user with email and password**
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) return null;

      return user;
    } catch (e) {
      print("Login Error: $e");
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
      print("Error checking user existence: $e");
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
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'currentLevel': 0,
        'currentXP': 0,
      });

      // Create `user_subtopics` collection
      await _firestore.collection('user_subtopics').doc(userId).set({
        'subtopicsCompleted': [],
      });

      // Add default settings in a subcollection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .set({
        'fontSize': 14,
        'profilePic': profilePic ?? "",
        'stayOnTrack': false,
      });

      print("✅ New LinkedIn user added to Firestore!");
    } catch (e) {
      print("Error registering LinkedIn user: $e");
    }
  }
}
