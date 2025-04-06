import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserProgress {
  final String subject;
  final int grade;
  final String unit;
  final int unitId;
  final String subtopic;
  final String subtopicId;
  final bool contentCompleted;
  final bool quizCompleted;
  final bool isCompleted;
  final int marksEarned;
  final DateTime? lastAccessed;

  UserProgress({
    required this.subject,
    required this.grade,
    required this.unit,
    required this.unitId,
    required this.subtopic,
    required this.subtopicId,
    required this.contentCompleted,
    required this.quizCompleted,
    required this.isCompleted,
    required this.marksEarned,
    required this.lastAccessed,
  });

  factory UserProgress.fromMap(Map<String, dynamic> data) {
    DateTime? parseLastAccessed(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return UserProgress(
      subject: data['subject'] ?? '',
      grade: data['grade'] is int
          ? data['grade']
          : int.tryParse(data['grade'].toString()) ?? 0,
      unit: data['unit'] ?? '',
      unitId: data['unit_id'] ?? 0,
      subtopic: data['subtopic'] ?? '',
      subtopicId: data['subtopic_id'] ?? '',
      contentCompleted: data['contentCompleted'] ?? false,
      quizCompleted: data['quizCompleted'] ?? false,
      isCompleted: data['isCompleted'] ?? false,
      marksEarned: data['marksEarned'] ?? 0,
      lastAccessed: parseLastAccessed(data['lastAccessed']),
    );
  }

  UserProgress copyWith({
    String? subject,
    int? grade,
    String? unit,
    int? unitId,
    String? subtopic,
    String? subtopicId,
    bool? contentCompleted,
    bool? quizCompleted,
    bool? isCompleted,
    int? marksEarned,
    DateTime? lastAccessed,
  }) {
    return UserProgress(
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      unit: unit ?? this.unit,
      unitId: unitId ?? this.unitId,
      subtopic: subtopic ?? this.subtopic,
      subtopicId: subtopicId ?? this.subtopicId,
      contentCompleted: contentCompleted ?? this.contentCompleted,
      quizCompleted: quizCompleted ?? this.quizCompleted,
      isCompleted: isCompleted ?? this.isCompleted,
      marksEarned: marksEarned ?? this.marksEarned,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }

  /// Optional: For display in the UI
  String get formattedLastAccessed {
    if (lastAccessed == null) return 'N/A';
    return DateFormat('MMM d, y').format(lastAccessed!);
  }
}
