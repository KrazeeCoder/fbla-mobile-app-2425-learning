import 'package:flutter/material.dart';
import 'package:fbla_mobile_2425_learning_app/pages/recent_lessons_homepage_UI.dart';
import 'package:fbla_mobile_2425_learning_app/pages/chooseyourownlesson_UI.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lessons"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Recent Lessons"),
              Tab(text: "Choose Your Lesson"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RecentLessonsUIPage(),
            ChooseLessonUIPage(),
          ],
        ),
      ),
    );
  }
}
