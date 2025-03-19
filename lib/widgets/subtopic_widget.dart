import 'package:flutter/material.dart';
import '../minigames/puzzle_game.dart';
<<<<<<< HEAD
import '../pages/chatbot_screen.dart';
=======
import '../minigames/maze_game.dart';
>>>>>>> 873907b (maze game beautify)

class SubtopicPage extends StatelessWidget {
  final String subtopic;
  final int subtopicId;
  final String readingTitle;
  final String readingContent;
  final Function onGameStart;

  const SubtopicPage({
    required this.subtopic,
    required this.subtopicId,
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
      body: Stack(
        children: [SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Styling
              Text(
                readingTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Splitting the content into formatted text widgets
              ..._formatText(readingContent),

              const SizedBox(height: 20),

<<<<<<< HEAD
              // Button to Start Game
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PuzzleScreen(subtopicId: subtopicId),
                      ),
                    );
                  },
                  child: const Text("Start Puzzle Game"),
                ),
=======
            // Button to Start Game
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MazeGame(subtopicId: subtopicId),
                    ),
                  );
                },
                child: const Text("Start maze Game"),
>>>>>>> 873907b (maze game beautify)
              ),
            ],
          ),
        ),
          Positioned(
            right: 20,
            bottom: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(), // Makes the button circular
                padding: EdgeInsets.all(20), // Adjust padding to control the size
              ),
              onPressed: () {Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatbotScreen(topicId: subtopicId.toString(),)),
              );},
              child: Icon(Icons.live_help),
          ))
      ]),
    );
  }

  /// Function to format the structured content using headings, bold text, and bullet points
  List<Widget> _formatText(String content) {
    List<Widget> formattedTextWidgets = [];
    List<String> lines = content.split("\n");

    for (String line in lines) {
      if (line.startsWith("### ")) {
        // Section Heading Formatting
        formattedTextWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              line.replaceFirst("### ", ""),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        );
      } else if (line.startsWith("- ")) {
        // Bullet Points Formatting with Bold Text Support
        formattedTextWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(fontSize: 16)),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      children: _formatBoldText(line.replaceFirst("- ", "")), // Apply bold formatting inside bullet points
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Regular Paragraph Text with Bold Formatting
        formattedTextWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: _formatBoldText(line),
              ),
            ),
          ),
        );
      }
    }

    return formattedTextWidgets;
  }

  /// Helper function to format **bold text** inside paragraphs and bullet points
  List<TextSpan> _formatBoldText(String text) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\*\*(.*?)\*\*'); // Match bold text
    int lastMatchEnd = 0;

    for (var match in exp.allMatches(text)) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd, match.start),
      ));
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastMatchEnd = match.end;
    }
    spans.add(TextSpan(text: text.substring(lastMatchEnd)));

    return spans;
  }
}
