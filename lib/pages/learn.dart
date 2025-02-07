import 'package:fbla_mobile_2425_learning_app/pages/recentlessons.dart';
import 'package:fbla_mobile_2425_learning_app/widgets/cypher_question.dart';
import 'package:flutter/material.dart';
import '../minigames/cypher_game.dart';
import '../widgets/earth_widget.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {


  void answerSelected(String asdf){
    print(asdf);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            CypherUI(),
          ],
        )

    return Scaffold(
        body: RecentLessonsPage()
    );
  }
}
