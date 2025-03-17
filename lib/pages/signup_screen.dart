import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  bool isLoading = false;
  final AuthService _authService = AuthService();

  /// **Handles user registration and Firestore data saving**
  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    String? result = await _authService.registerUser(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sign Up",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            TextField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: "First Name")),
            TextField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: "Last Name")),
            TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email Address")),
            TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true),
            TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: "Confirm Password"),
                obscureText: true),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: register,
              child:
              Text("Sign Up", style: TextStyle(color: Colors.white)),
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
