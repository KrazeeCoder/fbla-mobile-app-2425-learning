import 'package:fbla_mobile_2425_learning_app/pages/learn.dart';
import 'package:fbla_mobile_2425_learning_app/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/user_progress_model.dart';
import '../services/progress_service.dart';
import '../utils/game_launcher.dart';
import '../utils/subTopicNavigation.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/lessons.dart';
import '../widgets/level_bar_homepage.dart';
import '../widgets/recent_lessons_homepage.dart';
import '../widgets/streak_homepage.dart';
import 'subtopic_page.dart';
import '../widgets/xp_debug_controls.dart';
import '../services/xp_service.dart';
import '../managers/coach_marks/showcase_keys.dart';
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
    if (level >= 1 && level <= 15) return 'assets/earths/$level.svg';
    return 'assets/earths/5.svg';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final xpManager = Provider.of<XPService>(context);

    // Build the list of earths from level 1 to currentLevel
    final currentLevel = xpManager.currentLevel;

    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        // Make the entire homepage scrollable
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container for the top section with gradient background
            Column(
              children: [
                const SizedBox(height: 16),
                // Enhanced Level Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  // Keep the outer container for styling
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const LevelBarHomepage(),
                  ),
                ),
                const SizedBox(height: 20),
                // Earth Widget Section - Don't modify the Earth widget logic
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
                        final totalEarthLevels = 15;
                        final List<String> earthImages = List.generate(
                          totalEarthLevels,
                          (index) => _getEarthAssetPath(index + 1),
                        );

                        final PageController _pageController = PageController(
                          initialPage:
                              (currentLevel - 1).clamp(0, totalEarthLevels - 1),
                          viewportFraction: 0.6,
                        );

                        // Track current page to know when to show "back to current level" button
                        ValueNotifier<int> _currentPageNotifier =
                            ValueNotifier<int>((currentLevel - 1)
                                .clamp(0, totalEarthLevels - 1));

                        return Stack(
                          children: [
                            SizedBox(
                              height: screenHeight * 0.34,
                              width: screenWidth,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: earthImages.length,
                                onPageChanged: (index) {
                                  // Update current page
                                  _currentPageNotifier.value = index;
                                },
                                itemBuilder: (context, index) {
                                  final level = index + 1;
                                  final bool isLocked = level > currentLevel;
                                  final bool isCurrentLevel =
                                      level == currentLevel;

                                  return AnimatedBuilder(
                                    animation: _pageController,
                                    builder: (context, child) {
                                      double value = 1.0;
                                      if (_pageController
                                          .position.haveDimensions) {
                                        value = (_pageController.page! - index)
                                            .abs();
                                      } else {
                                        value = (_pageController.initialPage -
                                                index)
                                            .abs()
                                            .toDouble();
                                      }
                                      value =
                                          (1.2 - (value * 0.5)).clamp(0.6, 1.2);

                                      Widget earthVisual = GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              insetPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.only(
                                                    left: 20,
                                                    right: 12,
                                                    top: 20,
                                                    bottom:
                                                        20), // more left-heavy
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start, // aligns all children to left
                                                  children: [
                                                    const Text(
                                                      "🌍 Level Up Tip!",
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    const Text(
                                                      "Keep exploring to level up your Earth!",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      softWrap: false,
                                                      overflow:
                                                          TextOverflow.visible,
                                                    ),
                                                    const SizedBox(height: 12),
                                                    const Text(
                                                      "📘 Complete readings\n"
                                                      "🎮 Play games\n"
                                                      "🎯 Master quizzes\n"
                                                      "🏆 Earn XP and unlock new planets!",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        height: 1.5,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 24),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        style: TextButton
                                                            .styleFrom(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      20,
                                                                  vertical: 10),
                                                          backgroundColor:
                                                              const Color(
                                                                  0xFF4CAF50),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          "Got it! 🚀",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: SvgPicture.asset(
                                          earthImages[index],
                                          height: screenHeight * 0.22,
                                          width: screenHeight * 0.22,
                                          fit: BoxFit.contain,
                                        ),
                                      );

                                      if (isLocked) {
                                        earthVisual = Container(
                                          height: screenHeight * 0.22,
                                          width: screenHeight * 0.22,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.lock_outline_rounded,
                                              color: Colors.grey.shade600,
                                              size: 40,
                                            ),
                                          ),
                                        );
                                      }

                                      return Center(
                                        child: Transform.scale(
                                          scale: value,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              earthVisual,
                                              const SizedBox(height: 8),
                                              // Enhanced level indicator
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient: isLocked
                                                      ? null
                                                      : isCurrentLevel
                                                          ? const LinearGradient(
                                                              colors: [
                                                                Color(
                                                                    0xFF3A8C44),
                                                                Color(
                                                                    0xFF4CAF50),
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            )
                                                          : LinearGradient(
                                                              colors: [
                                                                Colors
                                                                    .blue[700]!,
                                                                Colors
                                                                    .blue[500]!,
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            ),
                                                  color: isLocked
                                                      ? Colors.grey.shade300
                                                      : null,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  boxShadow: isLocked
                                                      ? null
                                                      : [
                                                          BoxShadow(
                                                            color: isCurrentLevel
                                                                ? Color(0xFF3A8C44)
                                                                    .withOpacity(
                                                                        0.3)
                                                                : Colors
                                                                    .blue[700]!
                                                                    .withOpacity(
                                                                        0.3),
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // Icon based on level status
                                                    Icon(
                                                      isLocked
                                                          ? Icons.lock_outline
                                                          : isCurrentLevel
                                                              ? Icons
                                                                  .stars_rounded
                                                              : Icons
                                                                  .check_circle_outline,
                                                      size: 16,
                                                      color: isLocked
                                                          ? Colors.grey.shade700
                                                          : Colors.white,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Level $level',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isLocked
                                                            ? Colors
                                                                .grey.shade700
                                                            : Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            // "Back to current level" FAB that appears when not on current level
                            ValueListenableBuilder<int>(
                              valueListenable: _currentPageNotifier,
                              builder: (context, currentPage, child) {
                                final isNotAtCurrentLevel = currentPage !=
                                    (currentLevel - 1)
                                        .clamp(0, totalEarthLevels - 1);

                                return AnimatedPositioned(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  top: isNotAtCurrentLevel
                                      ? 8
                                      : -60, // Slides in from top
                                  right: 10, // 🔁 changed from left: to right:
                                  child: Material(
                                    elevation: 3,
                                    borderRadius: BorderRadius.circular(20),
                                    color: Color(
                                        0xFF37474F), // Blue-gray tone, clean and modern

                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () {
                                        _pageController.animateToPage(
                                          (currentLevel - 1)
                                              .clamp(0, totalEarthLevels - 1),
                                          duration:
                                              const Duration(milliseconds: 600),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        child: const Text(
                                          'Back to my level',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }),
              ],
            ),

            // Streak Section with Card-like design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: StreakHomepage(
                    userId: user?.uid ?? '',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Recent Lessons Section with improved styling
            const SizedBox(height: 4),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bookmark_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Pick Up Where You Left Off',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // Enhanced Recent Lesson Card
            Showcase(
              key: ShowcaseKeys.pickUpLessonKey,
              title: 'Continue Learning',
              description:
                  'Pick up right where you left off! Tap on a lesson to continue your learning journey.',
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FutureBuilder<List<UserProgress>>(
                  future: ProgressService.getHardcodedUserProgress(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          //padding
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "No recent lessons found. Start learning now!",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    // Find the first incomplete lesson, or fall back to the most recent one
                    UserProgress item;
                    final incompleteLesson = snapshot.data!.firstWhere(
                      (lesson) =>
                          !lesson.contentCompleted || !lesson.quizCompleted,
                      orElse: () => snapshot.data!.first,
                    );
                    item = incompleteLesson;

                    return RecentSingleLessonCard(
                      lesson: item,
                      onTap: () async {
                        final navData = await getSubtopicNavigationInfo(
                          subject: item.subject,
                          grade: item.grade,
                          subtopicId: item.subtopicId,
                          hardcoded: true,
                        );

                        final userId =
                            FirebaseAuth.instance.currentUser?.uid ?? '';

                        if (item.contentCompleted && !item.quizCompleted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShowCaseWidget(
                                builder: (context) => SubtopicPage(
                                  subtopic: item.subtopic,
                                  subtopicId: item.subtopicId,
                                  readingTitle: item.subtopic,
                                  readingContent:
                                      navData['readingContent'] ?? '',
                                  isCompleted: true,
                                  subject: item.subject,
                                  grade: item.grade,
                                  unitId: item.unitId,
                                  unitTitle: item.unit,
                                  userId: userId,
                                  lastSubtopicofUnit: navData['isLastOfUnit'],
                                  lastSubtopicofGrade: navData['isLastOfGrade'],
                                  lastSubtopicofSubject:
                                      navData['isLastOfSubject'],
                                ),
                              ),
                            ),
                          );
                        } else if (!item.contentCompleted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShowCaseWidget(
                                builder: (context) => SubtopicPage(
                                  subtopic: item.subtopic,
                                  subtopicId: item.subtopicId,
                                  readingTitle: item.subtopic,
                                  readingContent:
                                      navData['readingContent'] ?? '',
                                  isCompleted: false,
                                  subject: item.subject,
                                  grade: item.grade,
                                  unitId: item.unitId,
                                  unitTitle: item.unit,
                                  userId: userId,
                                  lastSubtopicofUnit: navData['isLastOfUnit'],
                                  lastSubtopicofGrade: navData['isLastOfGrade'],
                                  lastSubtopicofSubject:
                                      navData['isLastOfSubject'],
                                ),
                              ),
                            ),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title:
                                  const Text("🎉 You've completed this topic!"),
                              content:
                                  const Text("What would you like to do next?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ShowCaseWidget(
                                          builder: (context) => SubtopicPage(
                                            subtopic: item.subtopic,
                                            subtopicId: item.subtopicId,
                                            readingTitle: item.subtopic,
                                            readingContent:
                                                navData['readingContent'] ?? '',
                                            isCompleted: true,
                                            subject: item.subject,
                                            grade: item.grade,
                                            unitId: item.unitId,
                                            unitTitle: item.unit,
                                            userId: userId,
                                            lastSubtopicofUnit:
                                                navData['isLastOfUnit'],
                                            lastSubtopicofGrade:
                                                navData['isLastOfGrade'],
                                            lastSubtopicofSubject:
                                                navData['isLastOfSubject'],
                                          ),
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
                                        builder: (context) => ShowCaseWidget(
                                          builder: (context) => SubtopicPage(
                                            subtopic:
                                                navData['nextSubtopicTitle'],
                                            subtopicId:
                                                navData['nextSubtopicId'],
                                            readingTitle:
                                                navData['nextReadingTitle'],
                                            readingContent:
                                                navData['nextReadingContent'],
                                            isCompleted: false,
                                            subject: item.subject,
                                            grade: item.grade,
                                            unitId: navData['nextUnitId'],
                                            unitTitle: navData['nextUnitTitle'],
                                            userId: userId,
                                            lastSubtopicofUnit:
                                                navData['isLastOfUnit'],
                                            lastSubtopicofGrade:
                                                navData['isLastOfGrade'],
                                            lastSubtopicofSubject:
                                                navData['isLastOfSubject'],
                                          ),
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
            ),

            // Debug controls with better styling
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
            ),

            // Add some bottom padding
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
