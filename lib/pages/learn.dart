import 'package:flutter/material.dart';
import 'package:fbla_mobile_2425_learning_app/pages/recent_lessons_UI.dart';
import 'package:fbla_mobile_2425_learning_app/pages/chooseyourownlesson_UI.dart';
import 'package:fbla_mobile_2425_learning_app/widgets/custom_app_bar.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:fbla_mobile_2425_learning_app/coach_marks/showcase_keys.dart';
import 'package:provider/provider.dart';
import 'package:fbla_mobile_2425_learning_app/coach_marks/showcase_provider.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  bool _shouldShowCoachMarks = false;
  int _selectedTabIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // No need to check coach marks for now, we're focusing on the homepage level bar
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Function to handle tab switching
  void _switchTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Example of how to manually start a showcase
  void _startLearnShowcase() {
    // Using context.read<T>() extension
    context.read<ShowcaseService>().startLearnScreenShowcase(context);
  }

  // Example of how to start a custom showcase
  void _startCustomShowcase() {
    // Using the static method
    ShowcaseService.startCustomShowcase(context,
        [ShowcaseKeys.chooseLessonTabKey, ShowcaseKeys.selectSubjectKey]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomAppBar(),

          // Custom tab bar
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
                              color: _selectedTabIndex == 0
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
                            color: _selectedTabIndex == 0
                                ? Colors.black
                                : Colors.grey,
                            fontWeight: _selectedTabIndex == 0
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
                        // Switch to the Choose Your Lesson tab
                        _switchTab(1);
                      },
                      disposeOnTap: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedTabIndex == 1
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
                            color: _selectedTabIndex == 1
                                ? Colors.black
                                : Colors.grey,
                            fontWeight: _selectedTabIndex == 1
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

          // Content area with PageView for swiping
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              children: const [
                RecentLessonsUIPage(),
                ChooseLessonUIPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
