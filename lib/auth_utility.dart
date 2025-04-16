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
    required String username,
    required int age,
  }) async {
    try {
      print("🔐 Registering user with encryption for $email");
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
        'username': username, // Add unencrypted username
        'iv': encryptedUserInfo['iv'],
        'age': age,
        'currentLevel': 0,
        'currentXP': 0,
        'friends': [], // Initialize with empty friends list
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

  Future<bool> userExists(String email) async {
    try {
      // Attempt sign-in with wrong password to check if email exists
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: "random-wrong-password",
      );
      return true; // this shouldn't succeed
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return false; // ✅ Email does NOT exist
      } else if (e.code == 'invalid-credential') {
        print("❌  error: ${e.code} - ${e.message}");

        return true; // ✅ Email exists
      } else {
        print("❌ FirebaseAuth error: ${e.code} - ${e.message}");
        return false;
      }
    } catch (e) {
      print("❌ Unexpected error checking user existence: $e");
      return false;
    }
  }

  Future<bool> useridExists(String aid) async {
    try {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(aid).get();

      return docSnapshot.exists;
    } catch (e) {
      print("❌ Error checking document existence: $e");
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
    String? username, // Make username optional for LinkedIn
  }) async {
    try {
      print("🔐 Registering LinkedIn user with encryption for $userId");
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.uid != userId) {
        throw Exception("Logged-in user doesn't match LinkedIn UID.");
      }

      // Generate a unique username if not provided
      String actualUsername;

      if (username != null) {
        // Check if provided username is unique
        final usernameExists = await isUsernameTaken(username);
        if (usernameExists) {
          // If taken, generate a unique one
          actualUsername = await _generateUniqueUsername(firstName, lastName);
        } else {
          // Use the provided one if it's unique
          actualUsername = username;
        }
      } else {
        // Generate a unique username
        actualUsername = await _generateUniqueUsername(firstName, lastName);
      }

      // 🔐 Step 1: Set encryption key for this LinkedIn user
      await setLoginUserKeys(user);
      print('profile pic from LinkedIn: $profilePic');
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
        'username': actualUsername, // Add username
        'iv': encryptedUserInfo['iv'],
        'age': 0, // default age
        'currentLevel': 0,
        'currentXP': 0,
        'friends': [], // Initialize with empty friends list
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

  /// Generate a unique username based on first and last name
  Future<String> _generateUniqueUsername(
      String firstName, String lastName) async {
    // Base username format
    String baseUsername = '${firstName.toLowerCase()}${lastName.toLowerCase()}';

    // First try without any numbers
    if (!await isUsernameTaken(baseUsername)) {
      return baseUsername;
    }

    // Then try with a random 4-digit number
    int attempt = 1;
    String username;

    do {
      int randomSuffix = 1000 + attempt;
      username = '$baseUsername$randomSuffix';
      attempt++;

      // Safety check to prevent infinite loops
      if (attempt > 100) {
        // At this point, use a timestamp to ensure uniqueness
        username = '$baseUsername${DateTime.now().millisecondsSinceEpoch}';
        break;
      }
    } while (await isUsernameTaken(username));

    return username;
  }

  Future<void> updateUserProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String profilePic,
    String? username,
  }) async {
    // 🔒 Step 1: Encrypt all fields using your utility
    print("🔐 Updating profile Encrypting user profile for $uid");
    final encryptedUserInfo = await encryptUserInfoWithIV(
      uid,
      email,
      firstName,
      lastName,
      profilePic,
    );

    // Create update map
    Map<String, dynamic> updateData = {
      'email': encryptedUserInfo['email'],
      'firstName': encryptedUserInfo['firstname'],
      'lastName': encryptedUserInfo['lastname'],
      'iv': encryptedUserInfo['iv'],
      'settings': {
        'profilePic': encryptedUserInfo['profilePic'] ?? "",
      }
    };

    // Add username to update if provided
    if (username != null) {
      // Check if username is different than current one
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final currentUsername = userDoc.data()?['username'];

      if (username != currentUsername) {
        // Verify username is not taken by another user
        final isUsernameTaken = await this.isUsernameTaken(username);
        if (isUsernameTaken) {
          throw Exception("Username is already taken");
        }
        updateData['username'] = username;
      }
    }

    // 📝 Step 2: Save encrypted user info in Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
        updateData,
        SetOptions(merge: true)); // ✅ Prevents overwriting unrelated fields
  }

  /// Check if a user is logging in for the first time
  Future<bool> isFirstLogin(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return true; // New user if document doesn't exist
      }

      // Check if lastLogin field exists
      final userData = userDoc.data();
      if (userData == null || !userData.containsKey('lastLogin')) {
        // Mark this login as first by updating the lastLogin field
        await _firestore.collection('users').doc(userId).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
        return true;
      }

      // Not first login, but update the lastLogin timestamp
      await _firestore.collection('users').doc(userId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return false;
    } catch (e) {
      print("Error checking if first login: $e");
      return false; // Default to false if there's an error
    }
  }

  /// Check if a username is already taken
  Future<bool> isUsernameTaken(String username) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      print("Error checking username availability: $e");
      return true;
    }
  }
}


