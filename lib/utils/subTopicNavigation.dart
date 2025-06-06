import 'dart:convert';
import 'package:flutter/services.dart';

Future<Map<String, dynamic>> getSubtopicNavigationInfo({
  required String subject,
  required int grade,
  required String subtopicId,
  bool hardcoded = false,
}) async {
  final String jsonString;
  if (hardcoded) {
    return {
      // Current subtopic info
      'readingContent':
          "### 🧬 The Blueprint of Life — DNA Structure and Function\n\n**DNA (Deoxyribonucleic Acid)** is the molecule that holds the genetic instructions for all living organisms.\n\n- **Structure:** DNA is shaped like a double helix — imagine a twisted ladder.\n- **Components:**\n  - Sugar-phosphate backbone (the sides of the ladder)\n  - Nitrogenous bases (the rungs): Adenine (A), Thymine (T), Cytosine (C), Guanine (G)\n\n**Base Pairing Rules:**\n- Adenine (A) pairs with Thymine (T)\n- Cytosine (C) pairs with Guanine (G)\n\n**Why is DNA Important?**\n- Stores genetic information.\n- Controls cell growth, repair, and reproduction.\n- Passes traits from parents to offspring.\n\n**Fun Fact:**\nIf you stretched out all the DNA in one human cell, it would be about 2 meters long!",
      'readingTitle': "The Blueprint of Life",

      // Next subtopic info
      'nextSubtopicId': "g11_bio_2",
      'nextSubtopicTitle': "Genes and Chromosomes",
      'nextReadingContent':
          "Genes are segments of DNA that code for proteins and determine traits. Chromosomes are structures made of DNA that carry genes.",
      'nextReadingTitle': "From DNA to Traits",

      'nextUnitId': 1,
      'nextUnitTitle': "Biology: Genetics and Human Systems",

      // Position flags
      'isLastOfUnit': false,
      'isLastOfGrade': false,
      'isLastOfSubject': false,
      'nextGrade': 11,
    };
  } else {
    jsonString = await rootBundle.loadString('assets/content.json');
  }
  final Map<String, dynamic> data = json.decode(jsonString);

  final List<Map<String, dynamic>> flatList = [];
  int currentIndex = -1;
  int? nextGrade;

  for (final subjectMap in data['subjects']) {
    if (subjectMap['name'].toLowerCase() != subject.toLowerCase()) continue;

    final grades = subjectMap['grades'];

    for (int g = 0; g < grades.length; g++) {
      final gradeMap = grades[g];
      final gradeStr = gradeMap['grade'].toString().replaceAll('Grade ', '');
      final gradeNum = int.tryParse(gradeStr);

      if (gradeNum != grade) continue;

      // Determine next grade (if exists)
      if (g + 1 < grades.length) {
        final nextGradeStr =
            grades[g + 1]['grade'].toString().replaceAll('Grade ', '');
        nextGrade = int.tryParse(nextGradeStr);
      }

      final units = List<Map<String, dynamic>>.from(gradeMap['units']);

      for (int u = 0; u < units.length; u++) {
        final unit = units[u];
        final subtopics = List<Map<String, dynamic>>.from(unit['subtopics']);

        for (int s = 0; s < subtopics.length; s++) {
          final sub = subtopics[s];
          final subId = sub['subtopic_id'].toString();

          final entry = {
            'subtopic_id': subId,
            'subtopic_title': sub['subtopic'],
            'reading_content': sub['reading']?['content'] ?? "",
            'reading_title': sub['reading']?['title'] ?? "",
            'unitId': unit['unit_id'],
            'unitTitle': unit['unit'],
            'grade': grade,
            'subject': subject,
          };

          flatList.add(entry);

          if (subId == subtopicId) {
            currentIndex = flatList.length - 1;
          }
        }
      }
    }
  }

  if (currentIndex == -1) {
    throw Exception("Subtopic ID not found.");
  }

  final current = flatList[currentIndex];
  final next =
      currentIndex + 1 < flatList.length ? flatList[currentIndex + 1] : null;

  final bool isLastOfUnit = next == null || next['unitId'] != current['unitId'];
  final bool isLastOfGrade = next == null || next['grade'] != current['grade'];
  final bool isLastOfSubject =
      next == null || next['subject'] != current['subject'];

  return {
    // Current subtopic info
    'readingContent': current['reading_content'] ?? "",
    'readingTitle': current['reading_title'] ?? "",

    // Next subtopic info
    'nextSubtopicId': next?['subtopic_id'] ?? "",
    'nextSubtopicTitle': next?['subtopic_title'] ?? "",
    'nextReadingContent': next?['reading_content'] ?? "",
    'nextReadingTitle': next?['reading_title'] ?? "",
    'nextUnitId': next?['unitId'],
    'nextUnitTitle': next?['unitTitle'],

    // Position flags
    'isLastOfUnit': isLastOfUnit,
    'isLastOfGrade': isLastOfGrade,
    'isLastOfSubject': isLastOfSubject,
    'nextGrade': isLastOfGrade ? nextGrade : grade,
  };
}
