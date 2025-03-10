import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ChooseLessonPage extends StatefulWidget {
  const ChooseLessonPage({super.key});

  @override
  _ChooseLessonPageState createState() => _ChooseLessonPageState();
}

class _ChooseLessonPageState extends State<ChooseLessonPage> {
  Map<String, dynamic>? contentData;
  String? selectedSubject;
  List<Map<String, dynamic>> availableGrades = [];
  List<int> completedSubtopics = []; // Change from List<String> to List<int>


  @override
  void initState() {
    super.initState();
    loadJsonData();
    fetchUserCompletedLessons();
  }

  Future<void> loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/content.json');
    setState(() {
      contentData = json.decode(jsonString);
    });
  }

  Future<void> fetchUserCompletedLessons() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc('SKFMYGD4oclNQ2focMJN')
          .get();

      if (userDoc.exists) {
        setState(() {
          completedSubtopics = List<int>.from(userDoc['subtopicsCompleted']);
        });
        print("✅ Completed Subtopics from Firebase: $completedSubtopics"); // Debugging
      }
    } catch (e) {
      print("❌ Error fetching user data: $e");
    }
  }




  void updateGrades() {
    if (selectedSubject == null || contentData == null) return;

    var subjectData = contentData!['subjects']
        .firstWhere((s) => s['name'] == selectedSubject, orElse: () => null);

    if (subjectData != null && subjectData['grades'] is List) {
      availableGrades = (subjectData['grades'] as List)
          .map((g) => {
        'grade': g['grade'].toString().replaceAll("Grade ", ""),
        'subtopics': g['units']
            .expand((unit) => unit['subtopics'] as List)
            .map((sub) => {
          'subtopic_id': sub['subtopic_id'],
          'subtopic': sub['subtopic'],
        })
            .toList(),
      })
          .toList();
    } else {
      availableGrades = [];
    }

    setState(() {});
  }


  double calculateProgress(List subtopics) {
    if (subtopics.isEmpty) return 0.0;

    // Extract subtopic IDs as integers
    List<int> subtopicIds = subtopics.map<int>((s) => int.tryParse(s['subtopic_id'].toString()) ?? -1).toList();

    // Count how many are completed
    int completed = subtopicIds.where((id) => completedSubtopics.contains(id)).length;

    print("📊 Progress - Total: ${subtopicIds.length}, Completed: $completed");

    return completed / subtopicIds.length;
  }




  @override
  Widget build(BuildContext context) {
    List<String> subjects = contentData?['subjects'] != null
        ? (contentData!['subjects'] as List)
        .map((s) => (s as Map<String, dynamic>)['name'].toString())
        .toList()
        : [];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: DropdownButtonFormField<String>(
            value: selectedSubject,
            decoration: InputDecoration(
              labelText: "Select Subject",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: subjects.map((subject) {
              return DropdownMenuItem(value: subject, child: Text(subject));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedSubject = value;
                updateGrades();
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: availableGrades.length,
            itemBuilder: (context, index) {
              var gradeData = availableGrades[index];
              double progress = calculateProgress(gradeData['subtopics']);
              int percentage = (progress * 100).toInt();

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceholderPage(grade: gradeData['grade']),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.blue.shade300, width: 2),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 5,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation(Colors.blue),
                              ),
                              Center(
                                child: Text(
                                  "$percentage%",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Grade ${gradeData['grade']}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$percentage% completed",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.play_arrow, color: Colors.green, size: 30),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String grade;
  const PlaceholderPage({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Grade $grade")),
      body: Center(child: Text("This is a placeholder for Grade $grade")),
    );
  }
}