import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../xp_manager.dart';

class LevelBarHomepage extends StatelessWidget {
  const LevelBarHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access XPManager from provider
    final xpManager = Provider.of<XPManager>(context);

    // Show loading indicator while data is loading
    if (xpManager.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Calculate XP remaining until next level
    final int currentXP = xpManager.currentXP;
    final int minXP = xpManager.minXPForCurrentLevel;
    final int maxXP = xpManager.maxXPForCurrentLevel;
    final int xpRemaining = maxXP - currentXP;

    // Calculate progress for the progress bar
    final double progressValue = xpManager.levelProgress;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Level ${xpManager.currentLevel}",
                style: const TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$xpRemaining XP to level up",
                style: const TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(
              height: 8.0), // Adds space between text and progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressValue, // Use actual progress from XPManager
              backgroundColor:
                  const Color(0xFFF0DED1), // Softer background color
              color: const Color(0xFFF4903D), // Orange progress bar
              minHeight: 10.0, // A thicker progress bar
            ),
          ),
          const SizedBox(height: 4), // Add a small gap
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$currentXP XP",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                "$maxXP XP",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
