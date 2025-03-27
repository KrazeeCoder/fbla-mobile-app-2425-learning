import 'package:flutter/material.dart';

class GradeTile extends StatelessWidget {
  final String grade;
  final int total;
  final int completed;
  final double percent;

  const GradeTile({
    super.key,
    required this.grade,
    required this.total,
    required this.completed,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(value: percent / 100),
            Text("${percent.round()}%"),
          ],
        ),
        title: Text(grade, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$completed/$total subtopics completed"),
        trailing: const Icon(Icons.play_circle_outline),
        onTap: () {
          // TODO: Navigate to subtopics list for this grade
        },
      ),
    );
  }
}
