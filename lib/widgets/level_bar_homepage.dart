import 'package:flutter/material.dart';

class LevelBarHomepage extends StatelessWidget {
  const LevelBarHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Level 105",
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "300/500 XP",
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0), // Adds space between text and progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.6, // Adjust the value here for different progress
              backgroundColor: Color(0xFFD9F0D1), // Softer background color
              color: Color(0xFF2F9B4B), // Slightly darker green for the progress bar
              minHeight: 10.0, // A thicker progress bar
            ),
          ),
        ],
      ),
    );
  }
}
