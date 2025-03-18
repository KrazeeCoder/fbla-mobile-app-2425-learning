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
      // Create user with Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) return "Invalid registration information";

     // 📌 Store user data in Firestore (Settings grouped under 'settings' field)
    await _firestore.collection('users').doc(user.uid).set({
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'age': age, // ✅ Save age in Firestore
      'currentLevel': 0,
      'currentXP': 0,
      'settings': {  // ✅ Grouping settings inside a single object
        'fontSize': 14,
        'profilePic': "",
        'stayOnTrack': false,
      }
    });

      // Create subtopicsCompleted in a separate collection
      await _firestore.collection('user_subtopics').doc(user.uid).set({
        'subtopicsCompleted': [],
      });

      return "Success";
    } catch (e) {
      print("❌ Error registering user: $e");
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
