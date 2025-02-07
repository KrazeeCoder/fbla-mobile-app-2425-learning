import 'package:flutter/material.dart';
import '../widgets/lessons.dart'; // Import the LessonCard widget

class RecentLessonsPage extends StatelessWidget {
  //replace with Firebase data later
  final List<Lesson> lessons = [
    Lesson(subject: 'Math', grade: 'Grade 5', unit: 'Unit 3', subtopic: 'Subtopic 7'),
    Lesson(subject: 'Science', grade: 'Grade 6', unit: 'Unit 4', subtopic: 'Subtopic 2'),
    Lesson(subject: 'English', grade: 'Grade 7', unit: 'Unit 1', subtopic: 'Subtopic 3'),
    Lesson(subject: 'History', grade: 'Grade 8', unit: 'Unit 2', subtopic: 'Subtopic 5'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Recently Completed Lessons'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return LessonCard(
              lesson: lesson,
            );
          },
        ),
      ),
    );
  }
}
