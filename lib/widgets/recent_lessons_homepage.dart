import 'package:flutter/material.dart';
import '../widgets/lessons.dart';

class RecentLessonHomePage extends StatelessWidget {
  const RecentLessonHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Lesson> lessons = [
      Lesson(subject: 'Math', grade: 'Grade 5', unit: 'Unit 3', subtopic: 'Subtopic 7'),
      Lesson(subject: 'Science', grade: 'Grade 6', unit: 'Unit 4', subtopic: 'Subtopic 2'),
      Lesson(subject: 'English', grade: 'Grade 7', unit: 'Unit 1', subtopic: 'Subtopic 3'),
      Lesson(subject: 'History', grade: 'Grade 8', unit: 'Unit 2', subtopic: 'Subtopic 5'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Completed Lessons',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Wrap ListView.builder in a Container with max height for scrollability
        Container(
          height: 300, // Set a max height for this section
          child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return LessonCard(
                lesson: lesson,
              );
            },
          ),
        ),
      ],
    );
  }
}
