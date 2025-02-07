
import 'package:fbla_mobile_2425_learning_app/widgets/cypher_question.dart';
import 'package:flutter/material.dart';
import '../minigames/cypher_game.dart';
import '../widgets/earth_widget.dart';
import '../widgets/recent_lessons_homepage.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {



  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: RecentLessonsPage()
    );
  }
}
