import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/user_progress_model.dart';

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

class RecentSingleLessonCard extends StatelessWidget {
  final UserProgress lesson;
  final VoidCallback onTap;

  const RecentSingleLessonCard({
    super.key,
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(1, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(
                _getSubjectIcon(lesson.subject),
                size: 32,
                color: Colors.green.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lesson.subtopic, // 👉 Only subtopic title shown
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    const map = {
      'Math': Icons.calculate,
      'Science': Icons.science,
      'Reading': Icons.menu_book,
      'History': Icons.library_books,
    };
    return map[subject] ?? Icons.book;
  }
}
