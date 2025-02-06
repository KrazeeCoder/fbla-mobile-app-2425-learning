import 'package:flutter/material.dart';

class StreakHomepage extends StatelessWidget {
  const StreakHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Color(0xFFFFE4CF),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      onPressed: () => {},
      child: Padding(
        padding: EdgeInsets.all(3.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/streak_homepage_design.png",
              width: MediaQuery.sizeOf(context).width * 0.1,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                "575 Day Streak",
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFFFF8454),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

