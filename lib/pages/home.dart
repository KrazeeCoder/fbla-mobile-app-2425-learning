import 'package:fbla_mobile_2425_learning_app/widgets/streak_homepage.dart';
import 'package:flutter/material.dart';
import '../widgets/earth_widget.dart';
import '../widgets/level_bar_homepage.dart';

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
          title: const Text("Placeholder learning app title")
        ),
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              LevelBarHomepage(),
              EarthWidget(),
              StreakHomepage()
            ],
          ),
        )
    );
  }
}
