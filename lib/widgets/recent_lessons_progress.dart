import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../jsonUtility.dart';
import '../models/user_progress_model.dart';
import '../utils/app_logger.dart';
import '../widgets/subtopic_widget.dart';

class RecentLessonsTabWidget extends StatefulWidget {
  final Map<String, dynamic> userProgress;

  const RecentLessonsTabWidget({super.key, required this.userProgress});

  @override
  State<RecentLessonsTabWidget> createState() => _RecentLessonsTabWidgetState();
}

class _RecentLessonsTabWidgetState extends State<RecentLessonsTabWidget> {
  int _selectedTab = 0;
  List<Map<String, dynamic>> _recentLessons = [];
  List<Map<String, dynamic>> _completedLessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentLessons();
  }

  Future<void> _loadRecentLessons() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Get all lessons from content.json
      final allLessons = await _getAllLessons();

      // Process recent lessons
      final recentLessons = <Map<String, dynamic>>[];
      final completedLessons = <Map<String, dynamic>>[];

      // Iterate through user progress to find recent and completed lessons
      for (final entry in widget.userProgress.entries) {
        final lessonId = entry.key;
        final progress = entry.value as Map<String, dynamic>;

        // Find the lesson details from allLessons
        final lesson = allLessons.firstWhere(
          (l) => l['id'] == lessonId,
          orElse: () => <String, dynamic>{},
        );

        if (lesson.isNotEmpty) {
          // Add to recent lessons if it has a lastAccessed timestamp
          if (progress['lastAccessed'] != null) {
            recentLessons.add({
              ...lesson,
              ...progress,
              'lastAccessed': progress['lastAccessed'],
            });
          }

          // Add to completed lessons if it's completed
          if (progress['isCompleted'] == true) {
            completedLessons.add({
              ...lesson,
              ...progress,
              'completedAt':
                  progress['completedAt'] ?? progress['lastAccessed'],
            });
          }
        }
      }

      // Sort recent lessons by lastAccessed timestamp
      recentLessons.sort((a, b) {
        final aTime = a['lastAccessed'] as Timestamp;
        final bTime = b['lastAccessed'] as Timestamp;
        return bTime.compareTo(aTime);
      });

      // Sort completed lessons by completedAt timestamp
      completedLessons.sort((a, b) {
        final aTime = a['completedAt'] as Timestamp;
        final bTime = b['completedAt'] as Timestamp;
        return bTime.compareTo(aTime);
      });

      setState(() {
        _recentLessons = recentLessons;
        _completedLessons = completedLessons;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.e('Error loading recent lessons', error: e);
      setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _getAllLessons() async {
    try {
      final data = await loadJsonData();
      List<Map<String, dynamic>> lessons = [];

      for (final subject in data['subjects']) {
        for (final grade in subject['grades']) {
          for (final unit in grade['units']) {
            for (final subtopic in unit['subtopics']) {
              lessons.add({
                'id': subtopic['subtopic_id'],
                'title': subtopic['subtopic'],
                'subject': subject['name'],
                'grade': grade['grade'],
                'unit': unit['unit'],
                'unitId': unit['unit_id'],
                'reading': subtopic['reading']?['content'] ?? '',
              });
            }
          }
        }
      }

      return lessons;
    } catch (e) {
      AppLogger.e('Error getting all lessons', error: e);
      return [];
    }
  }

  void _navigateToLesson(Map<String, dynamic> lesson) {
    // Extract grade number from string like "Grade 3"
    final gradeString = lesson['grade'].toString();
    final gradeMatch = RegExp(r'(\d+)').firstMatch(gradeString);
    final gradeNumber =
        gradeMatch != null ? int.tryParse(gradeMatch.group(1) ?? '') ?? 1 : 1;

    // Navigate to the subtopic page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubtopicPage(
          subtopic: lesson['title'] ?? 'Lesson',
          subtopicId: lesson['id'] ?? '',
          readingTitle: lesson['title'] ?? 'Lesson',
          readingContent: lesson['reading'] ?? '',
          isCompleted: lesson['isCompleted'] ?? false,
          subject: lesson['subject'] ?? '',
          grade: gradeNumber,
          unitId: lesson['unitId'] ?? 0,
          unitTitle: lesson['unit'] ?? '',
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          lastSubtopicofUnit: false,
          lastSubtopicofGrade: false,
          lastSubtopicofSubject: false,
        ),
      ),
    ).then((_) {
      // Refresh the lists when returning from the subtopic page
      _loadRecentLessons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Switcher
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  'Recent',
                  0,
                  Icons.history_rounded,
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  'Completed',
                  1,
                  Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _selectedTab == 0
                  ? _buildRecentLessonsList()
                  : _buildCompletedLessonsList(),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentLessonsList() {
    if (_recentLessons.isEmpty) {
      return _buildEmptyState('No recent lessons');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _recentLessons.length,
      itemBuilder: (context, index) {
        final lesson = _recentLessons[index];
        return _buildLessonCard(lesson, false);
      },
    );
  }

  Widget _buildCompletedLessonsList() {
    if (_completedLessons.isEmpty) {
      return _buildEmptyState('No completed lessons');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _completedLessons.length,
      itemBuilder: (context, index) {
        final lesson = _completedLessons[index];
        return _buildLessonCard(lesson, true);
      },
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToLesson(lesson),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.shade50
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.book_rounded,
                    color: isCompleted
                        ? Colors.green.shade700
                        : Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson['title'] ?? 'Unknown lesson',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lesson['subject'] ?? 'Unknown'} • ${lesson['grade'] ?? 'Unknown grade'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
