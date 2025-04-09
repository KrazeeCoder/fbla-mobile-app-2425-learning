import 'package:flutter/material.dart';
import 'package:fbla_mobile_2425_learning_app/pages/recent_lessons_homepage_UI.dart';
import 'package:fbla_mobile_2425_learning_app/pages/chooseyourownlesson_UI.dart';
import 'package:provider/provider.dart';
import '../coach_marks/showcase_provider.dart';
import 'package:fbla_mobile_2425_learning_app/widgets/custom_app_bar.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  bool _shouldShowCoachMarks = false;

  @override
  void initState() {
    super.initState();
    // No need to check coach marks for now, we're focusing on the homepage level bar
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
