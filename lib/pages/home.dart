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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Learning App"),
      ),
      body: const SingleChildScrollView( // Wrapping body with SingleChildScrollView
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              LevelBarHomepage(),
              SizedBox(height: 32), // Increased space
              SizedBox(
                height: 200,
                child: EarthWidget(),
              ),
              SizedBox(height: 32), // Increased space
              StreakHomepage(), // Made bigger
              SizedBox(height: 24),
              RecentLessonHomePage(), // No need for Expanded
            ],
          ),
        ),
      ),
    );
  }
}
