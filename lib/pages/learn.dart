import 'package:flutter/material.dart';
import 'package:fbla_mobile_2425_learning_app/pages/recent_lessons_homepage_UI.dart';
import 'package:fbla_mobile_2425_learning_app/pages/chooseyourownlesson_UI.dart';
import 'package:fbla_mobile_2425_learning_app/widgets/custom_app_bar.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(), // Your logo and icons

            // Tab bar with no extra spacing
            TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.green,
              tabs: [
                Tab(text: "Recent Lessons"),
                Tab(text: "Choose Your Lesson"),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  RecentLessonsUIPage(),
                  ChooseLessonUIPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
