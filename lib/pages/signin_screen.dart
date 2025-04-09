import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'signup_screen.dart';
import 'home.dart';
import 'package:fbla_mobile_2425_learning_app/main.dart';
import '/auth_utility.dart';
import '/security.dart';
import '../coach_marks/showcase_provider.dart';

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
        await setLoginUserKeys(user);

        // Check if this is a first login for this user and trigger tutorial if needed
        final isNewUser = await _authService.isFirstLogin(user.uid);
        if (isNewUser) {
          Provider.of<ShowcaseProvider>(context, listen: false)
              .markTutorialNeeded();
        }

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

      // Check if running on Windows
      if (defaultTargetPlatform == TargetPlatform.windows) {
        // Show a dialog to tell the user this feature isn't available on Windows
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "LinkedIn login is not supported on Windows platform. Please use email login instead.")));
        }
        return;

        // Alternative: If you want to implement a Windows solution later
        // Use launchUrl from url_launcher package instead or implement a custom flow
      }

      final String result = await FlutterWebAuth.authenticate(
          url: authUrl, callbackUrlScheme: "fbla-learning-app");

      print("✅ LinkedIn OAuth Callback Result: $result");

      final Uri uri = Uri.parse(result);
      final String? firebaseToken = uri.queryParameters["firebaseToken"];
      final String? linkedinToken = uri.queryParameters["linkedinToken"];
      print("🔵 LinkedIn Token: $linkedinToken");

      await storeLinkedInToken(linkedinToken!);
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

      bool exists = await _authService.useridExists(user.uid);

      if (!exists) {
        print("🟢 New LinkedIn user detected, saving to Firestore...");
        await setLoginUserKeys(user);

        await _authService.registerUserFromLinkedIn(
          userId: user.uid,
          email: email ?? '',
          firstName: displayName?.split(" ").first ?? "Unknown",
          lastName: displayName?.split(" ").skip(1).join(" ") ?? "Unknown",
          profilePic: user?.photoURL,
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

  Future<void> storeLinkedInToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('linkedin_token', token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo and Name (Stacked vertically)
              Column(
                children: [
                  SvgPicture.asset(
                    'assets/branding/logo.svg',
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                  SvgPicture.asset(
                    'assets/branding/name.svg',
                    height: MediaQuery.of(context).size.height * 0.08,
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Welcome Text
              Text(
                "Welcome Back!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Please sign in to continue your learning journey",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Email Field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  prefixIcon:
                      Icon(Icons.email_outlined, color: Colors.green.shade800),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.green.shade800, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Password Field
              TextField(
                controller: passwordController,
                obscureText: obscureText,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon:
                      Icon(Icons.lock_outline, color: Colors.green.shade800),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.green.shade800,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.green.shade800, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Remember Me and Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        activeColor: Colors.green.shade800,
                        onChanged: (val) => setState(() => rememberMe = val!),
                      ),
                      Text(
                        "Remember me",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.green.shade800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sign In Button
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Colors.green.shade800))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: signInWithEmail,
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
              const SizedBox(height: 12),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SignUpScreen()),
                    ),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Divider with "or" text
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "or",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Social Login Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Google Button
                  InkWell(
                    onTap: () {
                      // TODO: Implement Google Sign In
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SvgPicture.asset(
                        'assets/login_options/google_logo.svg',
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),

                  // LinkedIn Button
                  InkWell(
                    onTap: signInWithLinkedIn,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SvgPicture.asset(
                        'assets/login_options/linkedin_logo.svg',
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),

                  // Apple Button
                  InkWell(
                    onTap: () {
                      // TODO: Implement Apple Sign In
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SvgPicture.asset(
                        'assets/login_options/apple_logo.svg',
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
