import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_progress_model.dart';
import '../services/progress_service.dart';
import '../utils/subTopicNavigation.dart';
import '../minigames/maze_game.dart';
import '../minigames/puzzle_game.dart';
import '../minigames/cypher_game.dart';
import '../minigames/racing_game.dart';
import '../minigames/quiz_challenge_game.dart';
import '../minigames/word_scramble_game.dart';
import '../widgets/subtopic_widget.dart';
import '../utils/game_launcher.dart';

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
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  final navData = await getSubtopicNavigationInfo(
                    subject: item.subject,
                    grade: item.grade,
                    subtopicId: item.subtopicId,
                  );

                  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

                  if (item.contentCompleted && !item.quizCompleted) {
                    await launchRandomGame(
                      context: context,
                      subject: item.subject,
                      grade: item.grade,
                      unitId: item.unitId,
                      unitTitle: item.unit,
                      subtopicId: item.subtopicId,
                      subtopicTitle: item.subtopic,
                      nextSubtopicId: navData['nextSubtopicId'],
                      nextSubtopicTitle: navData['nextSubtopicTitle'],
                      nextReadingContent: navData['nextReadingContent'],
                      userId: userId,
                    );
                    setState(_loadLessons);
                  } else if (!item.contentCompleted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubtopicPage(
                          subtopic: item.subtopic,
                          subtopicId: item.subtopicId,
                          readingTitle: item.subtopic,
                          readingContent: navData['readingContent'] ?? '',
                          isCompleted: false,
                          subject: item.subject,
                          grade: item.grade,
                          unitId: item.unitId,
                          unitTitle: item.unit,
                          userId: userId,
                          lastSubtopicofUnit: navData['isLastOfUnit'],
                          lastSubtopicofGrade: navData['isLastOfGrade'],
                          lastSubtopicofSubject: navData['isLastOfSubject'],
                        ),
                      ),
                    ).then((_) => setState(_loadLessons));
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("🎉 You've completed this topic!"),
                        content: const Text("What would you like to do next?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubtopicPage(
                                    subtopic: item.subtopic,
                                    subtopicId: item.subtopicId,
                                    readingTitle: item.subtopic,
                                    readingContent:
                                        navData['readingContent'] ?? '',
                                    isCompleted: true,
                                    subject: item.subject,
                                    grade: item.grade,
                                    unitId: item.unitId,
                                    unitTitle: item.unit,
                                    userId: userId,
                                    lastSubtopicofUnit: navData['isLastOfUnit'],
                                    lastSubtopicofGrade:
                                        navData['isLastOfGrade'],
                                    lastSubtopicofSubject:
                                        navData['isLastOfSubject'],
                                  ),
                                ),
                              ).then((_) => setState(_loadLessons));
                            },
                            child: const Text("📘 Review it again"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubtopicPage(
                                    subtopic: navData['nextSubtopicTitle'],
                                    subtopicId: navData['nextSubtopicId'],
                                    readingTitle: navData['nextReadingTitle'],
                                    readingContent:
                                        navData['nextReadingContent'],
                                    isCompleted: false,
                                    subject: item.subject,
                                    grade: item.grade,
                                    unitId: navData['nextUnitId'],
                                    unitTitle: navData['nextUnitTitle'],
                                    userId: userId,
                                    lastSubtopicofUnit: navData['isLastOfUnit'],
                                    lastSubtopicofGrade:
                                        navData['isLastOfGrade'],
                                    lastSubtopicofSubject:
                                        navData['isLastOfSubject'],
                                  ),
                                ),
                              ).then((_) => setState(_loadLessons));
                            },
                            child: const Text("➡️ Go to next subtopic"),
                          ),
                        ],
                      ),
                    );
                  }
                },
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              const SizedBox(height: 4),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Icon(Icons.play_arrow,
                            size: 30, color: Colors.black87),
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
