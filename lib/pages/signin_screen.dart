import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'signup_screen.dart';
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
  final AuthService _authService = AuthService();
  bool isLoading = false;
  bool rememberMe = false;
  bool obscureText = true;

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

    try {
      print("🔁 Starting LinkedIn sign-in flow...");

      if (defaultTargetPlatform == TargetPlatform.windows) {
        print("🪟 Windows platform detected. Aborting LinkedIn login.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "LinkedIn login is not supported on Windows platform. Please use email login instead.")));
        }
        return;
      }

      print("🌐 Launching LinkedIn auth URL: $authUrl");

      final String result = await FlutterWebAuth.authenticate(
          url: authUrl, callbackUrlScheme: "fbla-learning-app");

      print("✅ Auth callback received: $result");

      final Uri uri = Uri.parse(result);
      final String? firebaseToken = uri.queryParameters["firebaseToken"];
      final String? linkedinToken = uri.queryParameters["linkedinToken"];

      print(
          "📦 Extracted firebaseToken: ${firebaseToken?.substring(0, 10)}...");
      print(
          "📦 Extracted linkedinToken: ${linkedinToken?.substring(0, 10)}...");

      if (linkedinToken == null) {
        throw Exception("❌ LinkedIn token missing from callback URL.");
      }

      await storeLinkedInToken(linkedinToken);
      print("🔐 LinkedIn token stored successfully.");

      if (firebaseToken == null || firebaseToken.trim().isEmpty) {
        throw Exception("❌ Firebase token missing or empty.");
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
      print("🔓 Firebase sign-in successful.");

      User? user = userCredential.user;
      if (user == null) {
        throw Exception("❌ Firebase user is null after sign-in.");
      }

      print("👤 Signed-in user UID: ${user.uid}");

      IdTokenResult idTokenResult = await user.getIdTokenResult();
      Map<String, dynamic> claims = idTokenResult.claims ?? {};

      String? email = claims["email"];
      String? displayName = claims["displayName"];
      String? photoUrl = claims["photoURL"];

      print(
          "📧 Email: $email | 🧑‍🦰 Display Name: $displayName | 🖼️ Photo URL: $photoUrl");

      if (email != null && (user.email == null || user.email!.isEmpty)) {
        try {
          await user.updateEmail(email);
          print("✅ User email updated.");
        } catch (e) {
          print("⚠️ Email Update Failed: $e");
        }
      }

      if (displayName != null && user.displayName == null) {
        await user.updateDisplayName(displayName);
        print("✅ Display name updated.");
      }

      if (photoUrl != null && user.photoURL == null) {
        await user.updatePhotoURL(photoUrl);
        print("✅ Photo URL updated.");
      }

      await user.reload();
      user = FirebaseAuth.instance.currentUser;
      print("🔄 User reloaded.");

      if (user == null || user.email == null || user.email!.isEmpty) {
        throw Exception("❌ Email is still missing after Firebase sign-in!");
      }

      print("🔎 Checking if user ID exists in DB...");
      bool exists = await _authService.useridExists(user.uid);
      print("👤 User exists: $exists");

      if (!exists) {
        print("🆕 Registering new user in DB...");
        await setLoginUserKeys(user);
        await _authService.registerUserFromLinkedIn(
          userId: user.uid,
          email: email ?? '',
          firstName: displayName?.split(" ").first ?? "Unknown",
          lastName: displayName?.split(" ").skip(1).join(" ") ?? "Unknown",
          profilePic: user.photoURL,
        );
        print("✅ User registered.");
      }

      if (mounted) {
        print("➡️ Navigating to MainPage...");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => MainPage()));
      }
    } catch (e) {
      print("🚨 Exception during LinkedIn sign-in: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("LinkedIn Sign-In Failed: ${e.toString()}")));
      }
    }
  }

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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo and App Name
                      SvgPicture.asset('assets/branding/logo.svg', height: 130),
                      const SizedBox(height: 12),
                      SvgPicture.asset('assets/branding/name.svg', height: 45),
                      const SizedBox(height: 24),

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

                      // Email
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          prefixIcon: Icon(Icons.email_outlined,
                              color: Colors.green.shade800),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.green.shade800, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Password
                      TextField(
                        controller: passwordController,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Colors.green.shade800),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.green.shade800,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.green.shade800, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Remember Me
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                activeColor: Colors.green.shade800,
                                onChanged: (val) =>
                                    setState(() => rememberMe = val!),
                              ),
                              Text("Remember me",
                                  style:
                                      TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text("Forgot Password?",
                                style: TextStyle(color: Colors.green.shade800)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sign In Button
                      isLoading
                          ? CircularProgressIndicator(
                              color: Colors.green.shade800)
                          : ElevatedButton(
                              onPressed: signInWithEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade800,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
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
                          Text("Don't have an account?",
                              style: TextStyle(color: Colors.grey.shade600)),
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

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.grey.shade300),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text("or",
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: Divider(color: Colors.grey.shade300),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Social Login Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _socialIcon('assets/login_options/google_logo.svg',
                              onTap: () {}),
                          _socialIcon('assets/login_options/linkedin_logo.svg',
                              onTap: signInWithLinkedIn),
                          _socialIcon('assets/login_options/apple_logo.svg',
                              onTap: () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _socialIcon(String assetPath, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: SvgPicture.asset(assetPath, height: 24, width: 24),
      ),
    );
  }
}
