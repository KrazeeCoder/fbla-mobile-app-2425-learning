import 'package:flutter/material.dart';
import 'package:fbla_mobile_2425_learning_app/pages/recent_lessons_UI.dart';
import 'package:fbla_mobile_2425_learning_app/pages/chooseyourownlesson_UI.dart';
import 'package:fbla_mobile_2425_learning_app/widgets/custom_app_bar.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:fbla_mobile_2425_learning_app/coach_marks/showcase_keys.dart';
import 'package:fbla_mobile_2425_learning_app/pages/learn_pathway.dart'; // Import PathwayUI

// Define a callback type
typedef PathwayRequestedCallback = void Function(String subject, int grade,
    {String? highlightSubtopicId});

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  int _selectedTabIndex = 0;
  final PageController _pageController = PageController();

  // State for showing PathwayUI
  bool _showingPathway = false;
  String? _pathwaySubject;
  int? _pathwayGrade;
  String? _pathwayHighlightSubtopicId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showPathway(String subject, int grade, {String? highlightSubtopicId}) {
    setState(() {
      _showingPathway = true;
      _pathwaySubject = subject;
      _pathwayGrade = grade;
      _pathwayHighlightSubtopicId = highlightSubtopicId;
    });
  }

  void _hidePathway() {
    setState(() {
      _showingPathway = false;
      _pathwaySubject = null;
      _pathwayGrade = null;
      _pathwayHighlightSubtopicId = null;
    });
    // After hiding the pathway, ensure the PageView shows the correct page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        // Check if controller is attached
        _pageController.animateToPage(
          _selectedTabIndex, // Go to the last selected tab index
          duration: const Duration(
              milliseconds: 10), // Very short duration for quick sync
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Function to handle tab switching (only when not showing pathway)
  void _switchTab(int index) {
    if (_showingPathway) return; // Prevent switching tabs when pathway is shown
    setState(() {
      _selectedTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomAppBar(),

          // Conditionally include the tab bar
          if (!_showingPathway)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Recent Lessons Tab
                  Expanded(
                    child: InkWell(
                      onTap: () => _switchTab(0),
                      child: Showcase(
                        key: ShowcaseKeys.recentLessonTabKey,
                        title: 'Recent Lessons',
                        description: 'View your recent lessons here.',
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    _selectedTabIndex == 0 && !_showingPathway
                                        ? Colors.green
                                        : Colors.transparent,
                                width: 3.0,
                              ),
                            ),
                          ),
                          child: Text(
                            "Recent Lessons",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedTabIndex == 0 && !_showingPathway
                                  ? Colors.black
                                  : Colors.grey,
                              fontWeight:
                                  _selectedTabIndex == 0 && !_showingPathway
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Choose Your Lesson Tab
                  Expanded(
                    child: InkWell(
                      onTap: () => _switchTab(1),
                      child: Showcase(
                        key: ShowcaseKeys.chooseLessonTabKey,
                        title: 'Choose Your Lesson',
                        description: 'Choose your lesson here.',
                        onTargetClick: () {
                          _switchTab(1);
                        },
                        disposeOnTap: false,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    _selectedTabIndex == 1 && !_showingPathway
                                        ? Colors.green
                                        : Colors.transparent,
                                width: 3.0,
                              ),
                            ),
                          ),
                          child: Text(
                            "Choose Your Lesson",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedTabIndex == 1 && !_showingPathway
                                  ? Colors.black
                                  : Colors.grey,
                              fontWeight:
                                  _selectedTabIndex == 1 && !_showingPathway
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Content area: Conditionally show Pathway or PageView
          Expanded(
            child: WillPopScope(
              onWillPop: () async {
                if (_showingPathway) {
                  _hidePathway();
                  return false; // Prevent default pop
                }
                return true; // Allow default pop
              },
              child: _showingPathway
                  ? PathwayUI(
                      subject: _pathwaySubject!,
                      grade: _pathwayGrade!,
                      highlightSubtopicId: _pathwayHighlightSubtopicId,
                      onBackRequested: _hidePathway,
                      // userId will be fetched internally by PathwayUI
                    )
                  : PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        if (!_showingPathway) {
                          // Only update if not showing pathway
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        }
                      },
                      children: [
                        // Pass the callback to the children
                        RecentLessonsUIPage(onPathwayRequested: _showPathway),
                        ChooseLessonUIPage(onPathwayRequested: _showPathway),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
