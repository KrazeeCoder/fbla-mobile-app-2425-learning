import 'package:fbla_mobile_2425_learning_app/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/user_progress_model.dart';
import '../services/progress_service.dart';
import '../utils/game_launcher.dart';
import '../utils/subTopicNavigation.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/lessons.dart';
import '../widgets/level_bar_homepage.dart';
import '../widgets/recent_lessons_homepage.dart';
import '../widgets/streak_homepage.dart';
import '../widgets/subtopic_widget.dart';
import '../widgets/xp_debug_controls.dart';
import '../xp_manager.dart';
import '../coach_marks/showcase_keys.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  String _getEarthAssetPath(int level) {
    if (level <= 0) return 'assets/earths/1.svg';
    if (level >= 1 && level <= 5) return 'assets/earths/$level.svg';
    return 'assets/earths/5.svg';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final xpManager = Provider.of<XPManager>(context);

    // Build the list of earths from level 1 to currentLevel
    final currentLevel = xpManager.currentLevel;

    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        // Make the entire homepage scrollable
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Enhanced Level Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              // Keep the outer container for styling
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xA17AE645), Color(0x9E94E680)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const LevelBarHomepage(),
              ),
            ),
            const SizedBox(height: 16),
            // Earth Widget with Green Curved Shapes - Now dynamically selected based on level
            xpManager.isLoading
                ? Center(
                    child: Container(
                      height: screenHeight * 0.38,
                      width: screenHeight * 0.38,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    ),
                  )
                : Builder(builder: (context) {
                    final currentLevel = xpManager.currentLevel;
                    final maxVisualLevel =
                        currentLevel < 5 ? currentLevel + 1 : 5;

                    final List<String> earthImages = List.generate(
                      maxVisualLevel,
                      (index) => _getEarthAssetPath(index + 1),
                    );

                    final PageController _pageController = PageController(
                      initialPage: currentLevel - 1,
                      viewportFraction: 0.6,
                    );

                    bool isResettingPage = false;

                    return NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollUpdateNotification &&
                            !isResettingPage &&
                            _pageController.hasClients &&
                            _pageController.page != null &&
                            _pageController.page! > currentLevel - 1) {
                          isResettingPage = true;
                          _pageController
                              .animateToPage(
                                currentLevel - 1,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                              )
                              .then((_) => isResettingPage = false);
                          return true;
                        }
                        return false;
                      },
                      child: SizedBox(
                        height: screenHeight * 0.42,
                        width: screenWidth,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: earthImages.length,
                          itemBuilder: (context, index) {
                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double value = 1.0;
                                if (_pageController.position.haveDimensions) {
                                  value = (_pageController.page! - index).abs();
                                  value = (1.2 - (value * 0.5))
                                      .clamp(0.6, 1.2); // <-- max scale now 1.2
                                }
                                return Center(
                                  child: Transform.scale(
                                    scale: value,
                                    child: SvgPicture.asset(
                                      earthImages[index],
                                      height: screenHeight *
                                          0.4, // Center image will grow ~32% of screen height
                                      width: screenHeight *
                                          0.4, // Keep square proportion
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  }),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StreakHomepage(
                userId: user?.uid ?? '',
              ),
            ),
            const SizedBox(height: 24),
            // Enhanced Recent Lessons Title
            // 🆕 Updated Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    color: Colors.black,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Pick Up Where You Left Off',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      shadows: [
                        Shadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
// 🆕 Single Recent Lesson Showcase Wrapper
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FutureBuilder<List<UserProgress>>(
                future: ProgressService.fetchRecentLessons(user?.uid ?? "", latest: true),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No recent lessons");
                  }

                  final item = snapshot.data!.first;

                  return RecentSingleLessonCard(
                    lesson: item,
                    onTap: () async {
                      final navData = await getSubtopicNavigationInfo(
                        subject: item.subject,
                        grade: item.grade,
                        subtopicId: item.subtopicId,
                      );

                      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

                      if (item.contentCompleted && !item.quizCompleted) {
                        await launchRandomGame(
                          context: context,
                          subject: item.subject,
                          grade: item.grade,
                          unitId: item.unitId,
                          unitTitle: item.unit,
                          subtopicId: item.subtopicId,
                          subtopicTitle: item.subtopic,
                          nextSubtopicId: navData['nextSubtopicId'],
                          nextSubtopicTitle: navData['nextSubtopicTitle'],
                          nextReadingContent: navData['nextReadingContent'],
                          userId: userId,
                        );
                      } else if (!item.contentCompleted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubtopicPage(
                              subtopic: item.subtopic,
                              subtopicId: item.subtopicId,
                              readingTitle: item.subtopic,
                              readingContent: navData['readingContent'] ?? '',
                              isCompleted: false,
                              subject: item.subject,
                              grade: item.grade,
                              unitId: item.unitId,
                              unitTitle: item.unit,
                              userId: userId,
                              lastSubtopicofUnit: navData['isLastOfUnit'],
                              lastSubtopicofGrade: navData['isLastOfGrade'],
                              lastSubtopicofSubject: navData['isLastOfSubject'],
                            ),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("🎉 You've completed this topic!"),
                            content: const Text("What would you like to do next?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SubtopicPage(
                                        subtopic: item.subtopic,
                                        subtopicId: item.subtopicId,
                                        readingTitle: item.subtopic,
                                        readingContent: navData['readingContent'] ?? '',
                                        isCompleted: true,
                                        subject: item.subject,
                                        grade: item.grade,
                                        unitId: item.unitId,
                                        unitTitle: item.unit,
                                        userId: userId,
                                        lastSubtopicofUnit: navData['isLastOfUnit'],
                                        lastSubtopicofGrade: navData['isLastOfGrade'],
                                        lastSubtopicofSubject: navData['isLastOfSubject'],
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("📘 Review it again"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SubtopicPage(
                                        subtopic: navData['nextSubtopicTitle'],
                                        subtopicId: navData['nextSubtopicId'],
                                        readingTitle: navData['nextReadingTitle'],
                                        readingContent: navData['nextReadingContent'],
                                        isCompleted: false,
                                        subject: item.subject,
                                        grade: item.grade,
                                        unitId: navData['nextUnitId'],
                                        unitTitle: navData['nextUnitTitle'],
                                        userId: userId,
                                        lastSubtopicofUnit: navData['isLastOfUnit'],
                                        lastSubtopicofGrade: navData['isLastOfGrade'],
                                        lastSubtopicofSubject: navData['isLastOfSubject'],
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("➡️ Go to next subtopic"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),


            // Debug controls for XP testing (remove before production release)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: XPDebugControls(),
            ),

            // Add some bottom padding
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
