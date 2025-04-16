import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_progress_model.dart';
import '../services/progress_service.dart';
import '../utils/subTopicNavigation.dart';
import '../widgets/subtopic_widget.dart';
import '../utils/game_launcher.dart';
import 'package:fbla_mobile_2425_learning_app/pages/learn_pathway.dart';

class RecentLessonsUIPage extends StatefulWidget {
  final bool latestOnly;

  const RecentLessonsUIPage({super.key, this.latestOnly = false});

  @override
  State<RecentLessonsUIPage> createState() => _RecentLessonsUIPageState();
}

class _RecentLessonsUIPageState extends State<RecentLessonsUIPage> {
  late Future<List<UserProgress>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      setState(_loadLessons); // Refresh the lessons
      return true;
    });
  }

  void _loadLessons() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _lessonsFuture =
        ProgressService.fetchRecentLessons(userId, latest: widget.latestOnly);
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
        final displayLessons = widget.latestOnly ? [lessons.first] : lessons;

        return ListView.builder(
          itemCount: displayLessons.length,
          itemBuilder: (context, index) {
            final item = displayLessons[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PathwayUI(
                        subject: item.subject,
                        grade: item.grade,
                        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                        highlightSubtopicId: item.subtopicId,
                      ),
                    ),
                  );
                },
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _getSubjectIcon(item.subject),
                          size: 36,
                          color: Colors.black87,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12), // slightly tighter padding
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Main text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.subject,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Grade ${item.grade}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Subtopic: ${item.subtopic}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.quizCompleted
                                          ? "✅ Topic Completed"
                                          : item.contentCompleted
                                          ? "🎮 Game Remaining"
                                          : "📘 Continue Reading",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Arrow icon
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(
                                  Icons.play_arrow,
                                  size: 30,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
