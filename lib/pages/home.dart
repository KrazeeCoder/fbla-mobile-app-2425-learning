import 'package:flutter/material.dart';
import '../widgets/earth_widget.dart';
import '../widgets/lessons.dart';
import '../widgets/level_bar_homepage.dart';
import '../widgets/recent_lessons_homepage.dart';
import '../widgets/streak_homepage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // Get the screen height using MediaQuery
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Learning App"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const LevelBarHomepage(),
            const SizedBox(height: 16), // Reduced space between LevelBar and EarthWidget
            // Reduced EarthWidget height to make it smaller
            SizedBox(
              height: screenHeight * 0.2, // Adjust EarthWidget height to 20% of screen height
              child: const EarthWidget(),
            ),
            const SizedBox(height: 16), // Reduced space after EarthWidget
            const StreakHomepage(),
            const SizedBox(height: 24),
            // Add the "Recent Lessons" title in black
            const Text(
              'Recent Lessons',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Regular black color
              ),
            ),
            const SizedBox(height: 16), // Add some space after the title
            // Use Expanded to make sure RecentLessonsPage takes available space
            Expanded(
              child: RecentLessonsPage(), // Make RecentLessonsPage take available space
            ),
          ],
        ),
      ),
    );
  }
}
