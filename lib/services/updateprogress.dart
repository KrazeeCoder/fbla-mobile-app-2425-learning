import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> updateResumePoint({
  required String userId,
  required String subject,
  required String grade,
  required int unitId,
  required String unitName,
  required String subtopicId,
  required String subtopicName,
  required String actionType, // 'game' or 'content'
  required String actionState, // 'in_progress' or 'completed'
}) async {
  try {
    // Normalize document ID parts
    final cleanedUserId = userId.replaceAll(':', '_');
    final cleanedGrade = grade.replaceAll(' ', '');
    final cleanedSubject = subject.replaceAll(' ', '');

    // Construct document ID
    final docId = '${cleanedUserId}_${cleanedSubject}_$cleanedGrade';

    final docRef =
        FirebaseFirestore.instance.collection('resume_points').doc(docId);

    final data = {
      'subject': subject,
      'grade': grade,
      'unit_id': unitId,
      'unit_name': unitName,
      'subtopic_id': subtopicId,
      'subtopic_name': subtopicName,
      'action_type': actionType, // e.g., 'game' or 'content'
      'action_state': actionState, // e.g., 'in_progress' or 'completed'
      'last_accessed': FieldValue.serverTimestamp(),
    };

    await docRef.set(data, SetOptions(merge: true));

    print(
        '✅ Resume point saved for $userId → $grade - $subtopicName [$actionType | $actionState]');
  } catch (e) {
    print('❌ Error updating resume point: $e');
  }
}
