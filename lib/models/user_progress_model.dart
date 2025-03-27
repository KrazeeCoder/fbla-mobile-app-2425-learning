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
    return UserProgress(
      subject: data['subject'] ?? '',
      grade: data['grade'] ?? 0,
      unit: data['unit'] ?? '',
      unitId: data['unit_id'] ?? 0,
      subtopic: data['subtopic'] ?? '',
      subtopicId: data['subtopic_id'] ?? '',
      contentCompleted: data['contentCompleted'] ?? false,
      quizCompleted: data['quizCompleted'] ?? false,
      isCompleted: data['isCompleted'] ?? false,
      marksEarned: data['marksEarned'] ?? 0,
      lastAccessed: data['lastAccessed'] != null
          ? DateTime.tryParse(data['lastAccessed'])
          : null,
    );
  }
}
