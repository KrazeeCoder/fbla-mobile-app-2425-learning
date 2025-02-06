import 'package:fbla_mobile_2425_learning_app/widgets/streak_homepage.dart';
import 'package:flutter/material.dart';
import '../widgets/earth_widget.dart';
import '../widgets/level_bar_homepage.dart';
import '../widgets/recent_lessons_homepage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: LevelBarHomepage(),
                ),
                EarthWidget(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: StreakHomepage(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: RecentLessonsHomepage(),
                )
              ],
            ),
          ),
    );
  }
}
