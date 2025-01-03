import 'package:flutter/material.dart';






class LevelBarHomepage extends StatelessWidget {
  const LevelBarHomepage({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children:[
              Text("Level 105",
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                )
              ),
              Text("300/500 XP",
                  style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                  )
              )
            ]),
        LinearProgressIndicator(
          value: 0.5,
          backgroundColor: const Color(0xFF8DCF8D),
          color: const Color(0xFF1A730A),
          borderRadius: BorderRadius.circular(5),
        )
      ]
    );
  }
}
