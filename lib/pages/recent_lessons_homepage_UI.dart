import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_progress_model.dart';
import '../services/progress_service.dart';

class RecentLessonsUIPage extends StatefulWidget {
  const RecentLessonsUIPage({super.key});

  @override
  State<RecentLessonsUIPage> createState() => _RecentLessonsUIPageState();
}

class _RecentLessonsUIPageState extends State<RecentLessonsUIPage> {
  late Future<List<UserProgress>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _lessonsFuture = ProgressService.fetchRecentLessons(userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserProgress>>(
      future: _lessonsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No recent lessons found.'));
        }

        final lessons = snapshot.data!;

        return ListView.builder(
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final item = lessons[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    // Left Icon Section
                    Container(
                      width: 64,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16)),
                      ),
                      child: Icon(
                        _getSubjectIcon(item.subject),
                        size: 36,
                        color: Colors.black87,
                      ),
                    ),

                    // Middle Text Section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Subject + Grade
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.subject,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text("Grade ${item.grade}",
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(item.unit,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                )),
                            Text("Subtopic: ${item.subtopic}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                )),
                          ],
                        ),
                      ),
                    ),

                    // Right Play Button
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Icon(Icons.play_arrow,
                          size: 30, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
