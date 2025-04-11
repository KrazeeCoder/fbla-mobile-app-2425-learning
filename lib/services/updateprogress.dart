import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../xp_manager.dart';
import '../widgets/earth_unlock_animation.dart';
import '../utils/app_logger.dart';

Future<void> markSubtopicEntryIfFirstTime({
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

  final docSnapshot = await userDocRef.get();
  final existingData = docSnapshot.data();
  final existingSubtopic = existingData?[subtopicId] as Map<String, dynamic>?;

  if (existingSubtopic == null) {
    // First-time entry — create fresh
    final newProgress = {
      'subtopic_id': subtopicId,
      'subtopic': subtopicTitle,
      'unit': unitTitle,
      'unit_id': unitId,
      'grade': grade,
      'subject': subject,
      'contentCompleted': false,
      'quizCompleted': false,
      'marksEarned': 0,
      'startedAt': now,
      'lastAccessed': now,
      'lastActivityType': 'reading',
      'updatedAt': now,
      'isCompleted': false,
    };

    await userDocRef.set({subtopicId: newProgress}, SetOptions(merge: true));
  } else {
    // Update only specific fields while preserving others
    final updatedProgress = Map<String, dynamic>.from(existingSubtopic);
    updatedProgress['lastAccessed'] = now;
    updatedProgress['lastActivityType'] = 'reading';
    updatedProgress['updatedAt'] = now;

    await userDocRef
        .set({subtopicId: updatedProgress}, SetOptions(merge: true));
  }
}

Future<void> addResumePointIfFirstTime({
  required String userId,
  required String subject,
  required String grade,
  required int unitId,
  required String unitName,
  required String subtopicId,
  required String subtopicName,
  required String actionType, // 'content' or 'game'
}) async {
  try {
    final cleanedUserId = userId.replaceAll(':', '_');
    final cleanedGrade = grade.replaceAll(' ', '');
    final cleanedSubject = subject.replaceAll(' ', '');
    final docId = '${cleanedUserId}_${cleanedSubject}_$cleanedGrade';

    final docRef =
        FirebaseFirestore.instance.collection('resume_points').doc(docId);

    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      final data = {
        'subject': subject,
        'grade': grade,
        'unit_id': unitId,
        'unit_name': unitName,
        'subtopic_id': subtopicId,
        'subtopic_name': subtopicName,
        'action_type': actionType,
        'action_state': 'in_progress',
        'last_accessed': FieldValue.serverTimestamp(),
      };

      await docRef.set(data);
      print('✅ Resume point added: $docId [in_progress]');
    } else {
      print('ℹ️ Resume point already exists for: $docId. Skipping.');
    }
  } catch (e) {
    print('❌ Failed to add resume point: $e');
  }
}

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

Future<bool> isSubtopicCompleted({
  required String userId,
  required String subject,
  required String grade,
  required String subtopicId,
}) async {
  try {
    // Normalize for document ID
    final cleanedUserId = userId.replaceAll(':', '_');
    final cleanedGrade = grade.replaceAll(' ', '');
    final cleanedSubject = subject.replaceAll(' ', '');

    final docId = '${cleanedUserId}_${cleanedSubject}_$cleanedGrade';

    final docRef =
        FirebaseFirestore.instance.collection('resume_points').doc(docId);

    final snapshot = await docRef.get();

    if (!snapshot.exists) return false;

    final data = snapshot.data();
    if (data == null) return false;

    return data['subtopic_id'] == subtopicId &&
        data['action_state'] == 'completed';
  } catch (e) {
    print('❌ Error checking subtopic status: $e');
    return false;
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

void awardXPForCompletion({
  required BuildContext context,
  required bool unitCompleted,
  required bool gradeCompleted,
  required String subject,
  required String subtopicTitle,
}) {
  try {
    final xpManager = Provider.of<XPManager>(context, listen: false);

    int xpAmount = 10;
    if (unitCompleted) xpAmount += 10;
    if (gradeCompleted) xpAmount += 10;

    xpManager.addXP(xpAmount, onLevelUp: (newLevel) {
      showEarthUnlockedAnimation(
        context,
        newLevel,
        subject,
        subtopicTitle,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('+ $xpAmount XP earned!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  } catch (e) {
    AppLogger.e('Error awarding XP', error: e);
  }
}

// Show custom level up animation with earth unlocked
void showEarthUnlockedAnimation(
    BuildContext context, int newLevel, String subject, String subtopic) {
  try {
    final xpManager = Provider.of<XPManager>(context, listen: false);
    final totalXP = xpManager.currentXP;

    EarthUnlockAnimation.show(
      context,
      newLevel,
      subject,
      subtopic,
      totalXP,
    );
  } catch (e) {
    AppLogger.e('Error awarding XP in Cypher Game', error: e);
  }
}

Future<void> handleGameCompletion({
  required BuildContext context,
  required AudioPlayer audioPlayer,
  required String subtopicId,
  required String userId,
  required String subject,
  required int grade,
  required int unitId,
  required String unitTitle,
  required String subtopicTitle,
  required bool lastSubtopicofUnit,
  required bool lastSubtopicofGrade,
  required bool lastSubtopicofSubject,
}) async {
  // ✅ Play completion sound
  try {
    await audioPlayer.play(AssetSource('audio/congrats.mp3'));
  } catch (e) {
    AppLogger.w('Audio playback failed: $e');
  }

  // ✅ Determine what’s completed
  final bool unitCompleted = lastSubtopicofUnit;
  final bool gradeCompleted = lastSubtopicofGrade;
  final bool subjectCompleted = lastSubtopicofSubject;

  AppLogger.w(
    'Game completed: unitCompleted: $unitCompleted, gradeCompleted: $gradeCompleted, subjectCompleted: $subjectCompleted',
  );

  // ✅ Award XP based on progress
  awardXPForCompletion(
    context: context,
    unitCompleted: unitCompleted,
    gradeCompleted: gradeCompleted,
    subject: subject,
    subtopicTitle: subtopicTitle,
  );

  // ✅ Mark progress
  await markQuizAsCompleted(
    subtopicId: subtopicId,
    marksEarned: 10,
  );

  await updateResumePoint(
    userId: userId,
    subject: subject,
    grade: 'Grade $grade',
    unitId: unitId,
    unitName: unitTitle,
    subtopicId: subtopicId,
    subtopicName: subtopicTitle,
    actionType: 'game',
    actionState: 'completed',
  );
}

Future<void> HandleSubTopicStart({
  required String subtopicId,
  required String subtopicTitle,
  required String unitTitle,
  required int grade,
  required int unitId,
  required String subject,
}) async {
  await markSubtopicEntryIfFirstTime(
    subtopicId: subtopicId,
    subtopicTitle: subtopicTitle,
    unitTitle: unitTitle,
    grade: grade,
    unitId: unitId,
    subject: subject,
  );

  await addResumePointIfFirstTime(
    userId: FirebaseAuth.instance.currentUser!.uid,
    subject: subject,
    grade: 'Grade $grade',
    unitId: unitId,
    unitName: unitTitle,
    subtopicId: subtopicId,
    subtopicName: subtopicTitle,
    actionType: 'content',
  );
}
