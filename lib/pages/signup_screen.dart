import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/auth_utility.dart';
import 'signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode ageFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode(); // ✅ Added for confirm password

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
  final RegExp emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
  final RegExp ageRegex = RegExp(r"^[0-9]+$");
  final RegExp passwordRegex = RegExp(r"^(?=.*[0-9])(?=.*[!@#\$%^&*])(?=.{6,})");

  @override
  void initState() {
    super.initState();

    // Real-time validation listeners on focus loss
    firstNameFocus.addListener(() {
      if (!firstNameFocus.hasFocus) {
        setState(() {
          firstNameError = nameRegex.hasMatch(firstNameController.text)
              ? null
              : "Only letters allowed.";
        });
      }
    });

    lastNameFocus.addListener(() {
      if (!lastNameFocus.hasFocus) {
        setState(() {
          lastNameError = nameRegex.hasMatch(lastNameController.text)
              ? null
              : "Only letters allowed.";
        });
      }
    });

    emailFocus.addListener(() {
      if (!emailFocus.hasFocus) {
        setState(() {
          emailError = emailRegex.hasMatch(emailController.text)
              ? null
              : "Enter a valid email.";
        });
      }
    });

    ageFocus.addListener(() {
      if (!ageFocus.hasFocus) {
        setState(() {
          ageError = ageRegex.hasMatch(ageController.text)
              ? null
              : "Only numbers allowed.";
        });
      }
    });

    passwordFocus.addListener(() {
      if (!passwordFocus.hasFocus) {
        setState(() {
          passwordError = passwordRegex.hasMatch(passwordController.text)
              ? null
              : "At least 6 characters, 1 special character, 1 number required.";
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
      _showSnackBar("Fix the errors before proceeding.");
      return;
    }

    setState(() => isLoading = true);

    int? age = int.tryParse(ageController.text.trim());
    if (age == null || age <= 0) {
      _showSnackBar("Enter a valid age.");
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SignInScreen()),
      );
    } else {
      _showSnackBar(result ?? "Registration failed");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    String? errorText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Sign Up",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            _buildTextField(
              label: "First Name",
              controller: firstNameController,
              focusNode: firstNameFocus,
              errorText: firstNameError,
            ),

            _buildTextField(
              label: "Last Name",
              controller: lastNameController,
              focusNode: lastNameFocus,
              errorText: lastNameError,
            ),

            _buildTextField(
              label: "Email Address",
              controller: emailController,
              focusNode: emailFocus,
              errorText: emailError,
              keyboardType: TextInputType.emailAddress,
            ),

            _buildTextField(
              label: "Age",
              controller: ageController,
              focusNode: ageFocus,
              errorText: ageError,
              keyboardType: TextInputType.number,
            ),

            _buildTextField(
              label: "Password",
              controller: passwordController,
              focusNode: passwordFocus,
              errorText: passwordError,
              obscureText: true,
            ),

            _buildTextField(
              label: "Confirm Password",
              controller: confirmPasswordController,
              focusNode: confirmPasswordFocus,
              obscureText: true,
            ),

            const SizedBox(height: 20),

            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: register,
                child: const Text(
                  "Sign Up",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SignInScreen()),
              ),
              child: const Text("Already have an account? Sign In"),
            ),
          ],
        ),
      ),
    );
  }
}
