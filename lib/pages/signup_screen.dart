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
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  final AuthService _authService = AuthService();

  // Validation error messages
  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? birthdateError;
  String? passwordError;

  // Regex Patterns
  final RegExp nameRegex = RegExp(r"^[a-zA-Z]+$");
  final RegExp emailRegex =
      RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
  final RegExp passwordRegex =
      RegExp(r"^(?=.*[0-9])(?=.*[!@#\$%^&*])(?=.{6,})");

  Future<void> _selectBirthdate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now()
          .subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade800,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        birthdateController.text =
            "${picked.month}/${picked.day}/${picked.year}";
        // Calculate age
        final age = DateTime.now().difference(picked).inDays ~/ 365;
        if (age < 13) {
          birthdateError = "You must be at least 13 years old";
        } else {
          birthdateError = null;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Real-time validation listeners
    firstNameController.addListener(() {
      setState(() {
        firstNameError = nameRegex.hasMatch(firstNameController.text)
            ? null
            : "Only letters allowed!";
      });
    });

    lastNameController.addListener(() {
      setState(() {
        lastNameError = nameRegex.hasMatch(lastNameController.text)
            ? null
            : "Only letters allowed!";
      });
    });

    emailController.addListener(() {
      setState(() {
        emailError = emailRegex.hasMatch(emailController.text)
            ? null
            : "Enter a valid email!";
      });
    });

    passwordController.addListener(() {
      setState(() {
        passwordError = passwordRegex.hasMatch(passwordController.text)
            ? null
            : "At least 6 chars, 1 special char, 1 number required!";
      });
    });
  }

  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Passwords do not match");
      return;
    }

    if (firstNameError != null ||
        lastNameError != null ||
        emailError != null ||
        birthdateError != null ||
        passwordError != null) {
      _showSnackBar("Fix the errors before proceeding!");
      return;
    }

    setState(() => isLoading = true);

    // Calculate age from birthdate
    final birthdateParts = birthdateController.text.split('/');
    if (birthdateParts.length != 3) {
      _showSnackBar("Invalid birthdate format");
      setState(() => isLoading = false);
      return;
    }

    final birthdate = DateTime(
      int.parse(birthdateParts[2]),
      int.parse(birthdateParts[0]),
      int.parse(birthdateParts[1]),
    );
    final age = DateTime.now().difference(birthdate).inDays ~/ 365;

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

                // Birthdate Field
                TextField(
                  controller: birthdateController,
                  readOnly: true,
                  onTap: _selectBirthdate,
                  decoration: InputDecoration(
                    labelText: "Birthdate",
                    errorText: birthdateError,
                    prefixIcon: Icon(Icons.calendar_today,
                        color: Colors.green.shade800),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_month,
                          color: Colors.green.shade800),
                      onPressed: _selectBirthdate,
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
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: passwordController,
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
