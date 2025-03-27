import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_progress_model.dart';

class ProgressService {
  static Future<List<UserProgress>> fetchRecentLessons(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user_progress')
        .doc(userId)
        .get();

    if (!snapshot.exists) return [];

    final data = snapshot.data() as Map<String, dynamic>;
    final List<UserProgress> progressList = [];

    data.forEach((key, value) {
      progressList.add(UserProgress.fromMap(value));
    });

    // Sort by lastAccessed descending
    progressList.sort((a, b) =>
        b.lastAccessed?.compareTo(a.lastAccessed ?? DateTime(0)) ?? 0);

    return progressList;
  }
}
