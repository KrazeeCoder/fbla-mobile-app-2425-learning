import 'package:fbla_mobile_2425_learning_app/widgets/recent_lessons_homepage.dart';
import 'package:flutter/material.dart';

import '../widgets/chooseyourownlesson.dart';



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
            RecentLessonsPage(),
            ChooseLessonPage(),
          ],
        ),
      ),
    );
  }
}
