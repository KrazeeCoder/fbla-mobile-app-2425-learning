import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

class UserInfo {
  String email = '';
  String firstName = '';
  String userId = '';

  void setInfo(String email1, String firstName1){
    email = email1;
    firstName = firstName1;
    userId = FirebaseAuth.instance.currentUser!.uid;
  }
}

UserInfo userInfo = new UserInfo();


Future<String?> registerUser(String email, String password, String firstName, String lastName) async {
  try {
    // Create a user with email and password
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get the FirebaseUser
    User? user = userCredential.user;

    if (user != null) {
      // Store the user information in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        'currentLevel': 0,
        'currentXP': 0,
        'subtopicsCompleted': [],
        'settings': {'fontSize': 14, 'profilePic': 'default_pfp_202538.jpg', 'stayOnTrack': false}
      });

      // Set user information in global object
      userInfo.setInfo(email, firstName);
      return "Success";
    }
    // Case: User object is null
    return "Invalid registration information";
  } catch (e) {
    print("Error: $e");
    return "$e";
  }
}

Future<User?> loginUser(String email, String password) async {
  try {
    // Sign in with email and password
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get the signed-in user
    User? user = userCredential.user;
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    if (userDoc.exists) {
      // Set user information in global object
      userInfo.setInfo(userDoc.data()?['firstName'], email);
    }

    if (user != null) {
      print('User logged in');
      return user;
    }

    // Case: User object is null, meaning credentials were incorrect
    return null;
  } catch (e) {
    print("Error: $e");
    return null;
  }
}


