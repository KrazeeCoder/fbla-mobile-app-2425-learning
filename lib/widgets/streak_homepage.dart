import 'package:flutter/material.dart';

class StreakHomepage extends StatelessWidget {
  const StreakHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => {},
      child: Row(
        children: [
          Image.asset("assets/streak_homepage_design.png", width: MediaQuery.sizeOf(context).width*0.1),
          Text("575 Day Streak", style: TextStyle(fontSize: 35, color: Color(0xFFD83C00))) // can make this gradient orange later would look nice
        ]
      ),
    );
  }
}
