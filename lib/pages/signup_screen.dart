import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '/auth_utility.dart';
import 'signin_screen.dart';
import '../coach_marks/showcase_provider.dart';
import '../main.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Add FocusNodes
  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode ageFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  bool isLoading = false;
  final AuthService _authService = AuthService();

  // Validation error messages
  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? ageError;
  String? passwordError;

  // Regex Patterns
  final RegExp nameRegex = RegExp(r"^[a-zA-Z]+$");
  final RegExp emailRegex =
      RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
  final RegExp ageRegex = RegExp(r"^[0-9]+$");
  final RegExp passwordRegex =
      RegExp(r"^(?=.*[0-9])(?=.*[!@#\$%^&*])(?=.{6,})");

  @override
  void initState() {
    super.initState();

    // Real-time validation listeners on focus loss
    firstNameFocus.addListener(() {
      if (!firstNameFocus.hasFocus) {
        setState(() {
          if (firstNameController.text.isEmpty) {
            firstNameError = "First name cannot be blank!";
          } else {
            firstNameError = nameRegex.hasMatch(firstNameController.text)
                ? null
                : "Only letters allowed!";
          }
        });
      }
    });

    lastNameFocus.addListener(() {
      if (!lastNameFocus.hasFocus) {
        setState(() {
          if (lastNameController.text.isEmpty) {
            lastNameError = "Last name cannot be blank!";
          } else {
            lastNameError = nameRegex.hasMatch(lastNameController.text)
                ? null
                : "Only letters allowed!";
          }
        });
      }
    });

    emailFocus.addListener(() {
      if (!emailFocus.hasFocus) {
        setState(() {
          emailError = emailRegex.hasMatch(emailController.text)
              ? null
              : "Enter a valid email!";
        });
      }
    });

    ageFocus.addListener(() {
      if (!ageFocus.hasFocus) {
        setState(() {
          if (ageController.text.isEmpty) {
            ageError = "Age cannot be blank!";
          } else if (!ageRegex.hasMatch(ageController.text)) {
            ageError = "Only numbers allowed!";
          } else {
            int age = int.parse(ageController.text);
            if (age > 160) {
              ageError = "Please enter a valid age!";
            } else {
              ageError = null;
            }
          }
        });
      }
    });

    passwordFocus.addListener(() {
      if (!passwordFocus.hasFocus) {
        setState(() {
          passwordError = passwordRegex.hasMatch(passwordController.text)
              ? null
              : "At least 6 chars, 1 special char, 1 number required!";
        });
      }
    });
  }

  @override
  void dispose() {
    // Dispose controllers
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    ageController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    // Dispose focus nodes
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    emailFocus.dispose();
    ageFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();

    super.dispose();
  }

  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Passwords do not match");
      return;
    }

    if (firstNameError != null ||
        lastNameError != null ||
        emailError != null ||
        ageError != null ||
        passwordError != null) {
      _showSnackBar("Fix the errors before proceeding!");
      return;
    }

    setState(() => isLoading = true);

    int? age = int.tryParse(ageController.text.trim());
    if (age == null || age < 13 || age > 120) {
      _showSnackBar("Please enter a valid age between 13 and 120");
      setState(() => isLoading = false);
      return;
    }

    String? result = await _authService.registerUser(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      age: age,
    );

    setState(() => isLoading = false);

    if (result == "Success") {
      // Mark tutorial as needed using the ShowcaseProvider
      Provider.of<ShowcaseProvider>(context, listen: false)
          .markTutorialNeeded();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      _showSnackBar(result ?? "Registration failed");
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Join us to start your learning journey",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Name Fields in Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: firstNameController,
                        focusNode: firstNameFocus,
                        decoration: InputDecoration(
                          labelText: "First Name",
                          errorText: firstNameError,
                          prefixIcon: Icon(Icons.person_outline,
                              color: Colors.green.shade800),
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
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: lastNameController,
                        focusNode: lastNameFocus,
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          errorText: lastNameError,
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
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Email Field
                TextField(
                  controller: emailController,
                  focusNode: emailFocus,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    errorText: emailError,
                    prefixIcon: Icon(Icons.email_outlined,
                        color: Colors.green.shade800),
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
                const SizedBox(height: 16),

                // Age Field
                TextField(
                  controller: ageController,
                  focusNode: ageFocus,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Age",
                    errorText: ageError,
                    prefixIcon:
                        Icon(Icons.numbers, color: Colors.green.shade800),
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
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: passwordController,
                  focusNode: passwordFocus,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    errorText: passwordError,
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Colors.green.shade800),
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
                const SizedBox(height: 16),

                // Confirm Password Field
                TextField(
                  controller: confirmPasswordController,
                  focusNode: confirmPasswordFocus,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Colors.green.shade800),
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
                const SizedBox(height: 24),

                // Sign Up Button
                isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: Colors.green.shade800))
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade800,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: register,
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                const SizedBox(height: 16),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SignInScreen()),
                      ),
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
