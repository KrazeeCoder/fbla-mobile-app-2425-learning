import 'package:flutter/material.dart';
import 'package:fbla_mobile_2425_learning_app/pages/recent_lessons_UI.dart';
import 'package:fbla_mobile_2425_learning_app/pages/chooseyourownlesson_UI.dart';
import 'package:fbla_mobile_2425_learning_app/widgets/custom_app_bar.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:fbla_mobile_2425_learning_app/managers/coach_marks/showcase_keys.dart';
import 'package:fbla_mobile_2425_learning_app/pages/learn_pathway.dart'; // Import PathwayUI

// Define a callback type
typedef PathwayRequestedCallback = void Function(String subject, int grade,
    {String? highlightSubtopicId});

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _animationController;

  // State for showing PathwayUI
  bool _showingPathway = false;
  String? _pathwaySubject;
  int? _pathwayGrade;
  String? _pathwayHighlightSubtopicId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
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

    // Run the animation
    if (index == 0) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomAppBar(),

          // Title and welcome section
          if (!_showingPathway)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Learn",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Continue your learning journey",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

          // Improved tab bar with animation
          if (!_showingPathway)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Stack(
                  children: [
                    // Animated selection indicator
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Positioned(
                          left: _animationController.value *
                              (MediaQuery.of(context).size.width - 32) /
                              2,
                          top: 5,
                          bottom: 5,
                          width: (MediaQuery.of(context).size.width - 32) / 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Tab buttons
                    Row(
                      children: [
                        // Recent Lessons Tab
                        Expanded(
                          child: InkWell(
                            onTap: () => _switchTab(0),
                            child: Showcase(
                              key: ShowcaseKeys.recentLessonTabKey,
                              title: 'Recent Lessons',
                              description:
                                  'View and continue your recent learning activities here. Quickly pick up where you left off!',
                              titleTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                              descTextStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                              tooltipBackgroundColor: Colors.green.shade700,
                              overlayColor: Colors.black,
                              overlayOpacity: 0.7,
                              tooltipPadding: const EdgeInsets.all(16.0),
                              targetPadding: const EdgeInsets.all(8.0),
                              targetShapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              tooltipBorderRadius: BorderRadius.circular(10.0),
                              child: Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 16,
                                        color: _selectedTabIndex == 0
                                            ? primaryColor
                                            : Colors.grey.shade800,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Recent",
                                        style: TextStyle(
                                          color: _selectedTabIndex == 0
                                              ? primaryColor
                                              : Colors.grey.shade600,
                                          fontWeight: _selectedTabIndex == 0
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
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
                              title: 'Browse Lessons',
                              description:
                                  'Explore all available subjects and grades. Find new learning material and expand your knowledge!',
                              titleTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                              descTextStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                              tooltipBackgroundColor: Colors.green.shade700,
                              overlayColor: Colors.black,
                              overlayOpacity: 0.7,
                              tooltipPadding: const EdgeInsets.all(16.0),
                              targetPadding: const EdgeInsets.all(8.0),
                              targetShapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              tooltipBorderRadius: BorderRadius.circular(10.0),
                              onTargetClick: () {
                                _switchTab(1);
                              },
                              disposeOnTap: false,
                              child: Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.menu_book,
                                        size: 16,
                                        color: _selectedTabIndex == 1
                                            ? primaryColor
                                            : Colors.grey.shade800,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Browse",
                                        style: TextStyle(
                                          color: _selectedTabIndex == 1
                                              ? primaryColor
                                              : Colors.grey.shade800,
                                          fontWeight: _selectedTabIndex == 1
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Spacer after tabs
          if (!_showingPathway) const SizedBox(height: 8),

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
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            if (!_showingPathway) {
                              // Only update if not showing pathway
                              setState(() {
                                _selectedTabIndex = index;
                              });
                              // Run the animation
                              if (index == 0) {
                                _animationController.reverse();
                              } else {
                                _animationController.forward();
                              }
                            }
                          },
                          children: [
                            // Pass the callback to the children
                            RecentLessonsUIPage(
                                onPathwayRequested: _showPathway),
                            ChooseLessonUIPage(
                                onPathwayRequested: _showPathway),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
