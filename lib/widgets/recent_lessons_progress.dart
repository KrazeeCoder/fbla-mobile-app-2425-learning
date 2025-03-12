import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../main.dart';

class RecentLessonsTabWidget extends StatefulWidget {
  final Map<String, List<dynamic>> lessonsData;

  const RecentLessonsTabWidget({Key? key, required this.lessonsData}) : super(key: key);

  @override
  _RecentLessonsTabWidgetState createState() => _RecentLessonsTabWidgetState();
}

class _RecentLessonsTabWidgetState extends State<RecentLessonsTabWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = ["Math", "Science", "Reading", "History"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, int> calculateCompletedSubtopics(String category) {
    Map<String, int> completedPerGrade = {};
    List<dynamic> lessons = widget.lessonsData[category.toLowerCase()] ?? [];

    for (var subtopic in lessons) {
      if (completedPerGrade.containsKey(subtopic["grade"])) {
        completedPerGrade[subtopic["grade"]] = (completedPerGrade[subtopic["grade"]]! + 1);
      } else {
        completedPerGrade[subtopic["grade"]] = 1;
      }
    }

    return completedPerGrade;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.lightGreen[200],  // Light green background
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white, // Text color when selected
            unselectedLabelColor: Colors.black, // Text color when not selected
            labelStyle: TextStyle(fontWeight: FontWeight.bold), // Bold selected text
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            indicator: BoxDecoration(
              color: Colors.green[700], // Dark green for selected tab
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
            tabs: categories.map((category) => Tab(text: category)).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: categories.map((category) {
              Map<String, int> completedPerGrade = calculateCompletedSubtopics(category);
              List<String> gradeLevels = completedPerGrade.keys.toList();

              return ListView.builder(
                itemCount: gradeLevels.length,
                itemBuilder: (context, index) {
                  String grade = gradeLevels[index];
                  int completed = completedPerGrade[grade] ?? 0;
                  int total = allLessons[category.toLowerCase()]?["grade " + grade] ?? 1;
                  double progress = completed / total;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularPercentIndicator(
                            radius: 30.0,
                            lineWidth: 6.0,
                            percent: progress.clamp(0.0, 1.0),
                            center: Text("${(progress * 100).toInt()}%"),
                            progressColor: Colors.blue,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Grade $grade",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text("$completed/$total subtopics completed"),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.play_arrow, color: Colors.green, size: 32),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
