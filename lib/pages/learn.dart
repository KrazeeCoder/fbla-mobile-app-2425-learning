import 'package:fbla_mobile_2425_learning_app/pages/recentlessons.dart';
import 'package:flutter/material.dart';
import '../widgets/earth_widget.dart';

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
