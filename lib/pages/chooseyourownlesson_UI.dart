import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fbla_mobile_2425_learning_app/pages/learn.dart';
import 'package:fbla_mobile_2425_learning_app/pages/learn_pathway.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:fbla_mobile_2425_learning_app/coach_marks/showcase_keys.dart';
import '../coach_marks/showcase_provider.dart';
import 'package:provider/provider.dart';
import '../utils/app_logger.dart';

class ChooseLessonUIPage extends StatefulWidget {
  final PathwayRequestedCallback onPathwayRequested;

  const ChooseLessonUIPage({super.key, required this.onPathwayRequested});

  @override
  State<ChooseLessonUIPage> createState() => _ChooseLessonUIPageState();
}

class _ChooseLessonUIPageState extends State<ChooseLessonUIPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> contentData = {};
  String selectedSubject = "Math";
  List<String> availableSubjects = [];
  Map<String, dynamic> userProgress = {};
  bool isLoading = true;
  late AnimationController _animationController;

  // Subject color mapping for visual differentiation
  final Map<String, Color> subjectColors = {
    "Math": Color(0xFF5C4DB1), // Purple
    "Science": Color(0xFF4CAF50), // Green
    "Reading": Color(0xFF2196F3), // Blue
    "History": Color(0xFFFF9800), // Orange
  };

  // Subject-specific background patterns
  final Map<String, List<Color>> subjectGradients = {
    "Math": [Color(0xFFEDE7F6), Color(0xFFD1C4E9)], // Light purple gradient
    "Science": [Color(0xFFE8F5E9), Color(0xFFC8E6C9)], // Light green gradient
    "Reading": [Color(0xFFE3F2FD), Color(0xFFBBDEFB)], // Light blue gradient
    "History": [Color(0xFFFFF3E0), Color(0xFFFFE0B2)], // Light orange gradient
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    if (isLoading) {
      return Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            "Loading subjects...",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ));
    }

    final subjectData = contentData['subjects']
        .firstWhere((s) => s['name'] == selectedSubject, orElse: () => null);
    final grades = subjectData != null ? subjectData['grades'] : [];

    // Get current subject color and gradient
    final Color subjectColor =
        subjectColors[selectedSubject] ?? Color(0xFF5C4DB1);
    final List<Color> gradient = subjectGradients[selectedSubject] ??
        [Color(0xFFF5F5F5), Color(0xFFEEEEEE)];

    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _animationController,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradient,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject selection
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: subjectColor.withOpacity(0.15),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with subject icon
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          decoration: BoxDecoration(
                            color: subjectColor.withOpacity(0.1),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.book_rounded,
                                color: subjectColor,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Select a Subject",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: subjectColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Subject selector
                        Container(
                          height: 64,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              // Subject icon
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: subjectColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getSubjectIcon(selectedSubject),
                                  color: subjectColor,
                                  size: 24,
                                ),
                              ),

                              // Subject name
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    selectedSubject,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                              ),

                              // Dropdown button
                              Container(
                                decoration: BoxDecoration(
                                  color: subjectColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: subjectColor.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    icon: Icon(Icons.arrow_drop_down,
                                        color: subjectColor),
                                    hint: Text(
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
                                        // Animate when changing subject
                                        _animationController.reset();
                                        _animationController.forward();
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    underline: Container(),
                                    items: availableSubjects
                                        .toSet()
                                        .map((subject) {
                                      return DropdownMenuItem<String>(
                                        value: subject,
                                        child: Row(
                                          children: [
                                            Icon(_getSubjectIcon(subject),
                                                size: 18,
                                                color: subjectColors[subject]),
                                            SizedBox(width: 8),
                                            Text(
                                              subject,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    subject == selectedSubject
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Decorative element - subject-themed pattern
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(
                          _getDecorativeIcon(selectedSubject),
                          size: 14,
                          color: subjectColor.withOpacity(0.6),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 1.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  subjectColor.withOpacity(0.5),
                                  subjectColor.withOpacity(0.1),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Grade selection header with count badge
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Row(
                      children: [
                        Text(
                          "Select a Grade Level",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: subjectColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: subjectColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            "${grades.length} available",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: subjectColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Grade cards list
                  Expanded(
                    child: grades.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "No grades available for $selectedSubject",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.only(bottom: 20),
                            itemCount: grades.length,
                            itemBuilder: (context, index) {
                              final gradeData = grades[index];
                              final gradeLabel = gradeData['grade'];
                              final units = gradeData['units'] as List;

                              // Calculate progress
                              int totalSubtopics = 0;
                              int completed = 0;

                              for (var unit in units) {
                                for (var sub in unit['subtopics']) {
                                  totalSubtopics++;
                                  String subId = sub['subtopic_id'];
                                  if (userProgress[subId]?['isCompleted'] ==
                                      true) {
                                    completed++;
                                  }
                                }
                              }

                              final percent = totalSubtopics > 0
                                  ? (completed / totalSubtopics * 100).round()
                                  : 0;

                              // Extract numerical grade value for sorting/display
                              int gradeNumber = int.tryParse(gradeLabel
                                      .replaceAll(RegExp(r'[^0-9]'), '')) ??
                                  1;

                              Widget gradeCard = Container(
                                margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: subjectColor.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: percent > 0
                                        ? subjectColor.withOpacity(0.3)
                                        : Colors.grey.shade200,
                                    width: 1.5,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      widget.onPathwayRequested(
                                          selectedSubject, gradeNumber);
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Colored header with grade badge
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                subjectColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight: Radius.circular(16),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Grade number with badge
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: subjectColor
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: subjectColor
                                                        .withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  gradeLabel,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: subjectColor,
                                                  ),
                                                ),
                                              ),
                                              // Completion status
                                              if (percent >= 100)
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.green.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                      color:
                                                          Colors.green.shade300,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.check_circle,
                                                        color: Colors
                                                            .green.shade700,
                                                        size: 14,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        "Completed",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .green.shade700,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                        // Content section
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              // Progress circle
                                              SizedBox(
                                                width: 60,
                                                height: 60,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    // Background track
                                                    SizedBox(
                                                      width: 60,
                                                      height: 60,
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: 1.0,
                                                        strokeWidth: 6,
                                                        backgroundColor: Colors
                                                            .grey.shade200,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                Color>(
                                                          Colors.transparent,
                                                        ),
                                                      ),
                                                    ),
                                                    // Progress indicator
                                                    SizedBox(
                                                      width: 60,
                                                      height: 60,
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: percent / 100,
                                                        strokeWidth: 6,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                Color>(
                                                          subjectColor,
                                                        ),
                                                      ),
                                                    ),
                                                    // Center text
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          "$percent%",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: subjectColor,
                                                          ),
                                                        ),
                                                        Text(
                                                          "done",
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors
                                                                .grey.shade600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              SizedBox(width: 16),

                                              // Grade info
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "$completed of $totalSubtopics subtopics completed",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors
                                                            .grey.shade800,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    // Progress bar
                                                    Container(
                                                      height: 6,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: (completed /
                                                                    totalSubtopics) *
                                                                (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    160),
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  subjectColor,
                                                                  subjectColor
                                                                      .withOpacity(
                                                                          0.7),
                                                                ],
                                                                begin: Alignment
                                                                    .centerLeft,
                                                                end: Alignment
                                                                    .centerRight,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .menu_book_outlined,
                                                          size: 14,
                                                          color: subjectColor
                                                              .withOpacity(0.7),
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          "${totalSubtopics} lessons total",
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey.shade600,
                                                          ),
                                                        ),
                                                        Spacer(),
                                                        // Keep exploring prompt
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: subjectColor
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                          child: Text(
                                                            "Tap to explore",
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  subjectColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                              // Wrap only the first grade with showcase
                              if (index == 0) {
                                return Showcase(
                                  key: ShowcaseKeys.selectGradeKey,
                                  title: 'Select a Grade',
                                  description:
                                      'Tap on any grade to start learning that curriculum.',
                                  child: gradeCard,
                                  disposeOnTap: true,
                                  onTargetClick: () {
                                    widget.onPathwayRequested(
                                        selectedSubject, gradeNumber);
                                  },
                                );
                              }

                              return gradeCard;
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  IconData _getSubjectIcon(String subject) {
    final Map<String, IconData> icons = {
      'Math': Icons.calculate,
      'Science': Icons.science,
      'Reading': Icons.menu_book,
      'History': Icons.public,
    };

    return icons[subject] ?? Icons.book;
  }

  IconData _getDecorativeIcon(String subject) {
    final Map<String, IconData> icons = {
      'Math': Icons.calculate_outlined,
      'Science': Icons.science_outlined,
      'Reading': Icons.auto_stories_outlined,
      'History': Icons.history_edu_outlined,
    };

    return icons[subject] ?? Icons.school_outlined;
  }
}
