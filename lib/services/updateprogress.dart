import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> updateResumePoint({
  required String userId,
  required String subject,
  required String grade,
  required int unitId,
  required String unitName,
  required String subtopicId,
  required String subtopicName,
  required String actionType, // 'content' or 'game'
  required String actionState, // 'in_progress' or 'completed'
}) async {
  try {
    // Normalize parts for document ID
    final cleanedUserId = userId.replaceAll(':', '_');
    final cleanedGrade = grade.replaceAll(' ', '');
    final cleanedSubject = subject.replaceAll(' ', '');

    final docId = '${cleanedUserId}_${cleanedSubject}_$cleanedGrade';

    final DocumentReference<Map<String, dynamic>> docRef =
        FirebaseFirestore.instance.collection('resume_points').doc(docId);

    final data = {
      'subject': subject,
      'grade': grade,
      'unit_id': unitId,
      'unit_name': unitName,
      'subtopic_id': subtopicId,
      'subtopic_name': subtopicName,
      'action_type': actionType,
      'action_state': actionState,
      'last_accessed': FieldValue.serverTimestamp(),
    };

    await docRef.set(data, SetOptions(merge: true));

    print('✅ Resume point updated: $docId [$actionType | $actionState]');
  } catch (e) {
    print('❌ Failed to update resume point: $e');
  }
}

Future<void> markSubtopicAsCompleted({
  required String subtopicId,
  required String subtopicTitle,
  required String unitTitle,
  required int grade,
  required int unitId,
  required String subject,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userId = user.uid;
  final now = Timestamp.now();

  final userDocRef =
      FirebaseFirestore.instance.collection('user_progress').doc(userId);

  // Get current document (to check if entry exists)
  final docSnapshot = await userDocRef.get();
  final existingData = docSnapshot.data();
  final existingSubtopic = existingData?[subtopicId];

  final updatedProgress = {
    'subtopic_id': subtopicId,
    'subtopic': subtopicTitle,
    'unit': unitTitle,
    'unit_id': unitId,
    'grade': grade,
    'subject': subject,
    'contentCompleted': true,
    'contentCompletedAt': now,
    'quizCompleted': existingSubtopic?['quizCompleted'] ?? false,
    'quizCompletedAt': existingSubtopic?['quizCompletedAt'],
    'marksEarned': existingSubtopic?['marksEarned'] ?? 0,
    'startedAt': existingSubtopic?['startedAt'] ?? now,
    'lastAccessed': now,
    'lastActivityType': 'reading',
    'updatedAt': now,
    'isCompleted': (existingSubtopic?['quizCompleted'] ?? false),
  };

  //  Merge only the specific field for this subtopic ID
  await userDocRef.set({subtopicId: updatedProgress}, SetOptions(merge: true));
}

Future<void> markQuizAsCompleted({
  required String subtopicId,
  required int marksEarned,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userId = user.uid;
  final now = Timestamp.now();

  final userDocRef =
      FirebaseFirestore.instance.collection('user_progress').doc(userId);

  // Fetch existing progress map for this subtopic
  final docSnapshot = await userDocRef.get();
  final existingData = docSnapshot.data();
  final existingSubtopic = existingData?[subtopicId];

  if (existingSubtopic == null) {
    print(
        '[markQuizAsCompleted] ⚠️ Skipped: subtopicId $subtopicId not found in progress.');
    return;
  }

  // Merge into existing subtopic map
  final updatedSubtopic = Map<String, dynamic>.from(existingSubtopic);
  updatedSubtopic.addAll({
    'quizCompleted': true,
    'quizCompletedAt': now,
    'marksEarned': marksEarned,
    'updatedAt': now,
    'lastAccessed': now,
    'lastActivityType': 'quiz',
    'isCompleted': true,
  });

  await userDocRef.set(
    {subtopicId: updatedSubtopic},
    SetOptions(merge: true),
  );

  print('[markQuizAsCompleted] ✅ Updated quiz progress for $subtopicId');
}
