import 'package:flutter/material.dart';

import '../minigames/cypher_game.dart';


class SubtopicPage extends StatelessWidget {
  final String subtopic;
  final String readingTitle;
  final String readingContent;
  final Function onGameStart;

  const SubtopicPage({
    required this.subtopic,
    required this.readingTitle,
    required this.readingContent,
    required this.onGameStart,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subtopic),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              readingTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              readingContent,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Trigger the cipher game when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CypherUI(),
                  ),
                );
              },
              child: const Text("Start Cipher Game"),
            ),
          ],
        ),
      ),
    );
  }
}
