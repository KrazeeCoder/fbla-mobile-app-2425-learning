import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fbla_mobile_2425_learning_app/pages/learn_pathway.dart';

class ChooseLessonUIPage extends StatefulWidget {
  const ChooseLessonUIPage({super.key});

  @override
  State<ChooseLessonUIPage> createState() => _ChooseLessonUIPageState();
}

class _ChooseLessonUIPageState extends State<ChooseLessonUIPage> {
  Map<String, dynamic> contentData = {};
  String selectedSubject = "Math";
  List<String> availableSubjects = [];
  Map<String, dynamic> userProgress = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final String jsonString =
        await rootBundle.loadString('assets/content.json');
    contentData = jsonDecode(jsonString);

    availableSubjects = (contentData['subjects'] as List)
        .map((s) => s['name'].toString())
        .toList();

    final snapshot = await FirebaseFirestore.instance
        .collection('user_progress')
        .doc(uid)
        .get();

    userProgress = snapshot.data() ?? {};

    setState(() {
      isLoading = false;
      selectedSubject = availableSubjects.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final subjectData = contentData['subjects']
        .firstWhere((s) => s['name'] == selectedSubject, orElse: () => null);
    final grades = subjectData != null ? subjectData['grades'] : [];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(2, 2),
                  blurRadius: 2,
                ),
              ],
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Selected Subject (bold)
                Text(
                  selectedSubject,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Right: DropdownButton
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Color(0xFF225532)),
                    hint: const Text(
                      "select subject",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedSubject = value;
                        });
                      }
                    },
                    items: availableSubjects.toSet().map((subject) {
                      return DropdownMenuItem<String>(
                        value: subject,
                        child: Text(
                          subject,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
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
                  if (userProgress[subId]?['isCompleted'] == true) {
                    completed++;
                  }
                }
              }

              final percent = totalSubtopics > 0
                  ? (completed / totalSubtopics * 100).round()
                  : 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      // Circular progress
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
                                Color(0xFF5C4DB1), // Deep lavender
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
                      // Grade Info
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
                      IconButton(
                        icon: const Icon(Icons.play_arrow,
                            size: 32, color: Color(0xFF225532)),
                        onPressed: () {
                          int parsedGrade = int.tryParse(gradeLabel.replaceAll(
                                  RegExp(r'[^0-9]'), '')) ??
                              1;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PathwayUI(
                                subject: selectedSubject,
                                grade: parsedGrade,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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
