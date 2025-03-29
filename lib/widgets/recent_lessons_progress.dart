import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../pages/learn_pathway.dart';
import '../jsonUtility.dart';
import 'subject_summary_widget.dart';

class RecentLessonsTabWidget extends StatefulWidget {
  final Map<String, dynamic> userProgress; // ✅ Changed from List to Map

  const RecentLessonsTabWidget({Key? key, required this.userProgress})
      : super(key: key);

  @override
  _RecentLessonsTabWidgetState createState() => _RecentLessonsTabWidgetState();
}

class _RecentLessonsTabWidgetState extends State<RecentLessonsTabWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> dynamicSubjects = [];

  @override
  void initState() {
    super.initState();
    _initializeSubjects();
  }

  Future<void> _initializeSubjects() async {
    final data = await loadJsonData();
    final subjects = data["subjects"] as List<dynamic>;

    // Extract and sort unique subject names
    dynamicSubjects = subjects.map((s) => s["name"].toString()).toSet().toList()
      ..sort();

    _tabController = TabController(length: dynamicSubjects.length, vsync: this);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (dynamicSubjects.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Column(
        children: [
          // 🔵 TabBar for subjects
          Container(
            decoration: BoxDecoration(
              color: Colors.lightGreen[200],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.normal),
              indicator: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(8),
              ),
              isScrollable: true,
              tabs:
                  dynamicSubjects.map((subject) => Tab(text: subject)).toList(),
            ),
          ),

          // 🔵 Subject Summary inside scrollable container
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: dynamicSubjects.map((subject) {
                return FutureBuilder<Map<String, dynamic>>(
                  future: loadJsonData(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SubjectProgressSummary(
                        subject: subject,
                        userProgress: widget.userProgress, // ✅ Map input
                        contentData: snapshot.data!,
                        showSubjectTitle: false,
                        showPlayButton: true,
                        onPlayPressed: (grade) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PathwayUI(
                                grade: int.tryParse(grade) ?? 1,
                                subject: subject,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
