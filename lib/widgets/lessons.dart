import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Lesson {
  final String subject;
  final String grade;
  final String unit;
  final String subtopic;

  Lesson({
    required this.subject,
    required this.grade,
    required this.unit,
    required this.subtopic,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      subject: map['subject'] as String,
      grade: map['grade'] as String,
      unit: map['unit'] as String,
      subtopic: map['subtopic'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'grade': grade,
      'unit': unit,
      'subtopic': subtopic,
    };
  }
}

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap; // Added onTap callback parameter

  const LessonCard({
    required this.lesson,
    required this.onTap, // Initialize onTap
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData subjectIcon;
    switch (lesson.subject.toLowerCase()) {
      case 'math':
        subjectIcon = Icons.calculate;
        break;
      case 'science':
        subjectIcon = Icons.biotech;
        break;
      case 'history':
        subjectIcon = Icons.history;
        break;
      case 'language':
        subjectIcon = Icons.language;
        break;
      case 'computer science':
        subjectIcon = Icons.computer;
        break;
      default:
        subjectIcon = Icons.book;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          subjectIcon, // Dynamic subject icon
          size: 40,
          color: Colors.green,
        ),
        title: Text(
          lesson.subject,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${lesson.grade} | ${lesson.unit} | ${lesson.subtopic}'),
        trailing: const Icon(
          Icons.play_arrow,
          size: 30,
          color: Colors.green,
        ),
        onTap: onTap, // Trigger onTap when the card is tapped
      ),
    );
  }
}
