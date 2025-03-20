import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class RecentLessonsTabWidget extends StatefulWidget {
  final List<Map<String, dynamic>> lessonsData;

  const RecentLessonsTabWidget({Key? key, required this.lessonsData}) : super(key: key);

  @override
  _RecentLessonsTabWidgetState createState() => _RecentLessonsTabWidgetState();
}

class _RecentLessonsTabWidgetState extends State<RecentLessonsTabWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = ["Math", "Science", "English", "History"];

  // Map to store the total number of subtopics for each grade
  final Map<String, Map<String, int>> allLessons = {
    "math": {
      "grade 1": 85,
      "grade 2": 75,
      "grade 3": 90,
      "grade 4": 95,
      "grade 5": 80,
      "grade 8": 48
    },
    "english": {
      "grade 1": 67,
      "grade 2": 56,
      "grade 3": 90,
      "grade 4": 76,
      "grade 5": 75
    },
    "science": {
      "grade 1": 68,
      "grade 2": 98,
      "grade 3": 56,
      "grade 4": 96,
      "grade 5": 85
    },
    "history": {
      "grade 1": 80,
      "grade 2": 70,
      "grade 3": 82,
      "grade 4": 98,
      "grade 5": 87
    }
  };

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

  // Helper function to group lessons by subject and grade
  Map<String, Map<String, int>> groupLessonsBySubjectAndGrade() {
    Map<String, Map<String, int>> groupedData = {};

    for (var lesson in widget.lessonsData) {
      String subject = lesson["subject"].toLowerCase(); // Ensure lowercase to match allLessons keys
      String grade = "grade ${lesson["grade"]}"; // Ensure grade is in "grade X" format

      if (!groupedData.containsKey(subject)) {
        groupedData[subject] = {};
      }

      if (!groupedData[subject]!.containsKey(grade)) {
        groupedData[subject]![grade] = 0;
      }

      groupedData[subject]![grade] = groupedData[subject]![grade]! + 1;
    }

    return groupedData;
  }

  @override
  Widget build(BuildContext context) {
    // Group lessons by subject and grade
    Map<String, Map<String, int>> groupedData = groupLessonsBySubjectAndGrade();

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.lightGreen[200], // Light green background
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
              // Get the data for the current category
              Map<String, int>? gradeData = groupedData[category.toLowerCase()];

              if (gradeData == null || gradeData.isEmpty) {
                return Center(
                  child: Text("No data available for $category"),
                );
              }

              // Convert the grade data into a list of widgets
              return ListView.builder(
                itemCount: gradeData.length,
                itemBuilder: (context, index) {
                  String grade = gradeData.keys.elementAt(index);
                  int completed = gradeData[grade] ?? 0;

                  // Get the total number of subtopics for this grade from allLessons
                  int total = allLessons[category.toLowerCase()]?[grade] ?? 1;
                  double progress = completed / total;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
                                  grade,
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text("$completed/$total subtopics completed"),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.play_arrow,
                                color: Colors.green, size: 32),
                            onPressed: () {
                              // Handle play button press
                            },
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