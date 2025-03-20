import 'package:flutter/material.dart';

class StreakHomepage extends StatelessWidget {
  const StreakHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0), // Increased padding
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/streak_homepage_design.png",
            width: MediaQuery.of(context).size.width * 0.12, // Made the image a bit bigger
          ),
          const SizedBox(width: 10),
          Text(
            "575 Day Streak!",
            style: TextStyle(
              fontSize: 28, // Increased font size
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Color(0xFFFF8A00), Color(0xFFD83C00)],
                ).createShader(
                  const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                ),
            ),
          ),
        ],
      ),
    );
  }
}
