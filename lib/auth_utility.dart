import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './security.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **Logs out the current user and clears session**
  Future<void> logoutUser() async {
    try {
      await _auth.signOut(); // Sign out the user
      print("✅ User successfully logged out.");
    } catch (e) {
      print("❌ Logout Error: $e");
    }
  }

  /// Registers a new user with email and password, and stores encrypted info
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

      await setLoginUserKeys(user);

      // 🔐 Encrypt user info
      final encryptedUserInfo = await encryptUserInfoWithIV(
        user.uid,
        email,
        firstName,
        lastName,
        '', // profilePic is stored under settings, keep this empty
      );

      // Store encrypted fields in Firestore, keep profilePic under settings
      await _firestore.collection('users').doc(user.uid).set({
        'email': encryptedUserInfo['email'],
        'firstName': encryptedUserInfo['firstname'],
        'lastName': encryptedUserInfo['lastname'],
        'iv': encryptedUserInfo['iv'],
        'age': age,
        'currentLevel': 0,
        'currentXP': 0,
        'settings': {
          'fontSize': 14,
          'profilePic':
              "", // This is where profilePic stays (unencrypted or encrypted separately later)
          'stayOnTrack': false,
        }
      });

      // Initialize subtopics collection
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

  /// **Registers a new LinkedIn user in Firestore with encryption**
  Future<void> registerUserFromLinkedIn({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    required String? profilePic,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.uid != userId) {
        throw Exception("Logged-in user doesn't match LinkedIn UID.");
      }

      // 🔐 Step 1: Set encryption key for this LinkedIn user
      await setLoginUserKeys(user);

      // 🔒 Step 2: Encrypt user info (email, firstName, lastName)
      final encryptedUserInfo = await encryptUserInfoWithIV(
        user.uid,
        email,
        firstName,
        lastName,
        profilePic ??
            '', // Provide a default empty string if profilePic is null
      );

      // 📝 Step 3: Save encrypted user info in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': encryptedUserInfo['email'],
        'firstName': encryptedUserInfo['firstname'],
        'lastName': encryptedUserInfo['lastname'],
        'iv': encryptedUserInfo['iv'],
        'age': 0, // default age
        'currentLevel': 0,
        'currentXP': 0,
        'settings': {
          'fontSize': 14,
          'profilePic': encryptedUserInfo['profilePic'] ?? "",
          'stayOnTrack': false,
        }
      }, SetOptions(merge: true));

      // 📚 Step 4: Initialize user_subtopics
      await _firestore.collection('user_subtopics').doc(user.uid).set({
        'subtopicsCompleted': [],
      });

      print("✅ LinkedIn user registered with encryption!");
    } catch (e) {
      print("❌ Error registering LinkedIn user with encryption: $e");
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String profilePic,
  }) async {
    // 🔒 Step 1: Encrypt all fields using your utility
    final encryptedUserInfo = await encryptUserInfoWithIV(
      uid,
      email,
      firstName,
      lastName,
      profilePic,
    );

    // 📝 Step 2: Save encrypted user info in Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': encryptedUserInfo['email'],
      'firstName': encryptedUserInfo['firstname'],
      'lastName': encryptedUserInfo['lastname'],
      'iv': encryptedUserInfo['iv'],
      'settings': {
        'profilePic': encryptedUserInfo['profilepic'] ?? "",
      }
    }, SetOptions(merge: true)); // ✅ Prevents overwriting unrelated fields
  }
}
