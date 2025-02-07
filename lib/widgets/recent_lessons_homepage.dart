import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import '../minigames/cypher_game.dart';
import 'lessons.dart';
import 'subtopic_widget.dart';


class RecentLessonsPage extends StatelessWidget {
  const RecentLessonsPage({super.key});

  // Method to load JSON from assets
  Future<Map<String, dynamic>> loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/content.json');
    return json.decode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: loadJsonData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No data found.'));
        }

        final data = snapshot.data!;

        // Predefined list of lessons (with static content)
        final List<Lesson> lessons = [
          Lesson(subject: 'Math', grade: 'Grade 5', unit: 'Algebra', subtopic: 'One-variable Equations'),
          Lesson(subject: 'Science', grade: 'Grade 6', unit: 'Physics', subtopic: 'Motion'),
          Lesson(subject: 'English', grade: 'Grade 7', unit: 'Literature', subtopic: 'Shakespeare'),
          Lesson(subject: 'History', grade: 'Grade 8', unit: 'Ancient Civilizations', subtopic: 'Rome'),
        ];

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];

                // Fetch content from the JSON dynamically when tapped
                return LessonCard(
                  lesson: lesson,
                  onTap: () async {
                    if (kDebugMode) {
                      print("Card tapped");
                    }

                    // Find the subtopic data based on the lesson
                    final subject = data['subjects'].firstWhere(
                          (subject) => subject['name'] == lesson.subject,
                      orElse: () => null,
                    );
                    if (subject == null) {
                      return;
                    }

                    final grade = subject['grades'].firstWhere(
                          (grade) => grade['grade'] == lesson.grade,
                      orElse: () => null,
                    );
                    if (grade == null) {
                      return;
                    }

                    final unit = grade['units'].firstWhere(
                          (unit) => unit['unit'] == lesson.unit,
                      orElse: () => null,
                    );
                    if (unit == null) {
                      return;
                    }

                    final subtopic = unit['subtopics'].firstWhere(
                          (sub) => sub['subtopic'] == lesson.subtopic,
                      orElse: () => null,
                    );

                    // Set content fallback if no content found
                    final readingTitle = subtopic?['reading']?['title'] ?? 'No title available';
                    final readingContent = subtopic?['reading']?['content'] ?? 'No content available';

                    // Navigate to the SubtopicPage with the lesson content
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubtopicPage(
                          subtopic: lesson.subtopic,
                          readingTitle: readingTitle,
                          readingContent: readingContent,
                          onGameStart: () {
                            // When game starts, navigate to the cipher game
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CypherUI(),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
