import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/auth_utility.dart';
import 'signin_screen.dart';

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
  final TextEditingController confirmPasswordController = TextEditingController();

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

    ageController.addListener(() {
      setState(() {
        ageError = ageRegex.hasMatch(ageController.text)
            ? null
            : "Only numbers allowed!";
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
      ageError != null ||
      passwordError != null) {
    _showSnackBar("Fix the errors before proceeding!");
    return;
  }

  setState(() => isLoading = true);

  // Convert age to an integer (ensure it's valid)
  int? age = int.tryParse(ageController.text.trim());
  if (age == null || age <= 0) {
    _showSnackBar("Enter a valid age!");
    setState(() => isLoading = false);
    return;
  }

  String? result = await _authService.registerUser(
    email: emailController.text.trim(),
    password: passwordController.text.trim(),
    firstName: firstNameController.text.trim(),
    lastName: lastNameController.text.trim(),
    age: age, // ✅ Pass age here
  );

  setState(() => isLoading = false);

  if (result == "Success") {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => SignInScreen()));
  } else {
    _showSnackBar(result ?? "Registration failed");
  }
}


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sign Up", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

            // First Name Field
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: "First Name",
                errorText: firstNameError,
              ),
            ),

            // Last Name Field
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: "Last Name",
                errorText: lastNameError,
              ),
            ),

            // Email Field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email Address",
                errorText: emailError,
              ),
            ),

            // Age Field
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Age",
                errorText: ageError,
              ),
            ),

            // Password Field
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                errorText: passwordError,
              ),
              obscureText: true,
            ),

            // Confirm Password Field
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: "Confirm Password"),
              obscureText: true,
            ),

            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: register,
                    child: Text("Sign Up", style: TextStyle(color: Colors.white)),
                  ),

            TextButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => SignInScreen())),
              child: Text("Already have an account? Sign In"),
            ),
          ],
        ),
      ),
    );
  }
}
