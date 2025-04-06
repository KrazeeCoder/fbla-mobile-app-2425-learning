import 'package:flutter/material.dart';

class SubjectProgressSummary extends StatelessWidget {
  final String subject;
  final Map<String, dynamic> userProgress; // ✅ Changed to Map
  final Map<String, dynamic> contentData;
  final bool showPlayButton;
  final bool showSubjectTitle;
  final void Function(String grade)? onPlayPressed;

  const SubjectProgressSummary({
    super.key,
    required this.subject,
    required this.userProgress, // ✅ Use progress Map
    required this.contentData,
    this.showPlayButton = false,
    this.showSubjectTitle = true,
    this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final subjectData = (contentData['subjects'] as List).firstWhere(
      (s) => s['name'].toLowerCase() == subject.toLowerCase(),
      orElse: () => null,
    );

    if (subjectData == null) return const SizedBox.shrink();
    final grades = subjectData['grades'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSubjectTitle)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              subject,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: grades.length,
          itemBuilder: (context, index) {
            final gradeData = grades[index];
            final gradeLabel = gradeData['grade'];
            final units = gradeData['units'] as List;

            int totalSubtopics = 0;
            int completed = 0;

            for (var unit in units) {
              for (var sub in unit['subtopics']) {
                totalSubtopics++;
                String subId = sub['subtopic_id'];

                // ✅ Check userProgress for isCompleted flag
                if (userProgress[subId]?['isCompleted'] == true) {
                  completed++;
                }
              }
            }

            final percent = totalSubtopics > 0
                ? (completed / totalSubtopics * 100).round()
                : 0;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.blue.shade300,
                  width: 1.2,
                ),
              ),
              elevation: 4,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: CircularProgressIndicator(
                            value: percent / 100,
                            strokeWidth: 4.5,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF5C4DB1),
                            ),
                          ),
                        ),
                        Text(
                          "$percent%",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gradeLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$completed/$totalSubtopics subtopics completed",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showPlayButton)
                      IconButton(
                        icon: const Icon(Icons.play_arrow,
                            size: 32, color: Color(0xFF225532)),
                        onPressed: () {
                          if (onPlayPressed != null) {
                            final gradeNum =
                                gradeLabel.replaceAll(RegExp(r'\D'), '');
                            onPlayPressed!(gradeNum);
                          }
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
