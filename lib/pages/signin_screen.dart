import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'signup_screen.dart';
import 'home.dart';
import 'package:fbla_mobile_2425_learning_app/main.dart';
import '/auth_utility.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService =
  AuthService(); // Avoid redundant instantiation
  bool isLoading = false;
  bool rememberMe = false;
  bool obscureText = true; // Password visibility toggle

  /// **Sign in with Email**
  Future<void> signInWithEmail() async {
    if (!_isValidEmail(emailController.text)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid email format.")));
      return;
    }

    setState(() => isLoading = true);

    try {
      User? user = await _authService.loginUser(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => MainPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login failed: Invalid credentials.")));
      }
    } catch (e) {
      print("Login Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${e.toString()}")));
    }

    setState(() => isLoading = false);
  }

  Future<void> signInWithLinkedIn() async {
    final String clientId = "86jqgl7o5plvlv";
    final String redirectUri =
        "https://us-central1-voxigo.cloudfunctions.net/myLinkedInServer/auth/linkedin/callback";
    final String scope = "openid+profile+w_member_social+email";

    final String authUrl =
        "https://www.linkedin.com/oauth/v2/authorization?response_type=code"
        "&client_id=$clientId&redirect_uri=${Uri.encodeComponent(redirectUri)}&scope=$scope";

    print("🔵 LinkedIn OAuth URL: $authUrl");

    try {
      print("🔵 Opening LinkedIn OAuth WebView...");
      final String result = await FlutterWebAuth.authenticate(
          url: authUrl, callbackUrlScheme: "fbla-learning-app");

      print("✅ LinkedIn OAuth Callback Result: $result");

      final Uri uri = Uri.parse(result);
      final String? firebaseToken = uri.queryParameters["firebaseToken"];

      if (firebaseToken == null || firebaseToken.trim().isEmpty) {
        throw Exception("❌ Firebase token missing or empty.");
      }

      print("🔵 Signing in with Firebase Custom Token...");
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);

      User? user = userCredential.user;
      if (user == null) {
        throw Exception("❌ Firebase user is null after sign-in.");
      }

      print("✅ Firebase User Signed In: ${user.uid}");

      // 🚀 Retrieve Custom Claims from ID Token
      IdTokenResult idTokenResult = await user.getIdTokenResult();
      Map<String, dynamic> claims = idTokenResult.claims ?? {};

      print("🔍 Extracted Custom Claims: $claims");

      // 🔍 Extract LinkedIn metadata from custom claims
      String? email = claims["email"];
      String? displayName = claims["displayName"];
      String? photoUrl = claims["photoURL"];

      print("🟢 Extracted Email from Claims: ${email ?? 'NULL'}");
      print("🟢 Extracted Display Name from Claims: ${displayName ?? 'NULL'}");
      print("🟢 Extracted Photo URL from Claims: ${photoUrl ?? 'NULL'}");

      if (email != null && (user.email == null || user.email!.isEmpty)) {
        try {
          print("🔵 Updating Firebase Email...");
          await user.updateEmail(email); // ✅ FIXED: Direct update
        } catch (e) {
          print("⚠️ Email Update Failed: $e (May already be set)");
        }
      }

      if (displayName != null && user.displayName == null) {
        await user.updateDisplayName(displayName);
      }

      if (photoUrl != null && user.photoURL == null) {
        await user.updatePhotoURL(photoUrl);
      }

      await user.reload();
      user = FirebaseAuth.instance.currentUser;

      print("✅ Updated Firebase User:");
      print("🟢 UID: ${user?.uid}");
      print("🟢 Email: ${user?.email}");
      print("🟢 Display Name: ${user?.displayName}");
      print("🟢 Photo URL: ${user?.photoURL}");

      if (user == null || user.email == null || user.email!.isEmpty) {
        throw Exception("❌ Email is still missing after Firebase sign-in!");
      }

      bool exists = await _authService.userExists(email!);

      if (!exists) {
        print("🟢 New LinkedIn user detected, saving to Firestore...");
        await _authService.registerUserFromLinkedIn(
          userId: user.uid,
          email: email,
          firstName: displayName?.split(" ").first ?? "Unknown",
          lastName: displayName?.split(" ").skip(1).join(" ") ?? "Unknown",
          profilePic: photoUrl,
        );
      } else {
        print("🔵 Existing LinkedIn user detected, skipping Firestore update.");
      }

      print("🚀 Redirecting to MainPage...");
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => MainPage()));
      }
    } catch (e) {
      print("❌ LinkedIn Sign-In Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("LinkedIn Sign-In Failed: ${e.toString()}")));
      }
    }
  }

  /// **Validates email format**
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome Back!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Please sign in to continue",
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email Address"),
            ),
            TextField(
              controller: passwordController,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Checkbox(
                    value: rememberMe,
                    onChanged: (val) => setState(() => rememberMe = val!)),
                Text("Remember me"),
                TextButton(onPressed: () {}, child: Text("Forgot Password?")),
              ],
            ),
            SizedBox(height: 10),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: signInWithEmail,
              child:
              Text("Sign In", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => SignUpScreen())),
              child: Text("Don't have an account? Sign Up"),
            ),
            Divider(),
            ElevatedButton.icon(
              onPressed: signInWithLinkedIn,
              icon: Icon(Icons.work_outline),
              label: Text("Continue with LinkedIn"),
            ),
          ],
        ),
      ),
    );
  }
}
