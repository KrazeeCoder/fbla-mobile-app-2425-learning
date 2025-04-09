import 'package:fbla_mobile_2425_learning_app/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/earth_widget.dart';
import '../widgets/lessons.dart';
import '../widgets/level_bar_homepage.dart';
import '../widgets/recent_lessons_homepage.dart';
import '../widgets/streak_homepage.dart';
import '../widgets/xp_debug_controls.dart';
import '../xp_manager.dart';
import '../coach_marks/showcase_keys.dart';
import '../coach_marks/showcase_provider.dart';
import 'package:showcaseview/showcaseview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showcaseTriggered = false;

  @override
  void initState() {
    super.initState();
  }

  // Function to determine which Earth to display based on level
  String _getEarthAssetPath(int level) {
    // Direct mapping: Level 1 -> Earth 1, Level 2 -> Earth 2, etc.
    // For levels beyond 5, show Earth 5 (the most developed Earth)
    if (level <= 0) {
      return 'assets/earths/1.svg'; // Default to first Earth for level 0 or negative
    } else if (level >= 1 && level <= 5) {
      return 'assets/earths/$level.svg'; // Direct mapping
    } else {
      return 'assets/earths/5.svg'; // Max at Earth 5 for higher levels
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen height and width using MediaQuery
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Access XPManager to get current level
    final xpManager = Provider.of<XPManager>(context);

    // Access ShowcaseProvider
    final showcaseProvider =
        Provider.of<ShowcaseProvider>(context, listen: false);

    return Scaffold(
      appBar: CustomAppBar(),
      body: ShowCaseWidget(
        onStart: (index, key) {
          AppLogger.i("Showcase started with index: $index");
        },
        onComplete: (index, key) {
          if (index == null) {
            AppLogger.i("Showcase completed");
            showcaseProvider.markShowcaseComplete();
          }
        },
        builder: (context) => Builder(
          builder: (builderContext) {
            // Use a Builder to get the correct context that has access to ShowCaseWidget
            if (!_showcaseTriggered) {
              _showcaseTriggered = true;
              // Delay to ensure all widgets are properly laid out
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AppLogger.i("Attempting to start showcase");
                try {
                  // This context is now within the ShowCaseWidget's builder
                  final ShowCaseWidgetState? showCaseState =
                      ShowCaseWidget.of(builderContext);
                  if (showCaseState != null) {
                    showCaseState.startShowCase([ShowcaseKeys.levelBarKey]);
                    AppLogger.i("Showcase started successfully");
                  } else {
                    AppLogger.e("ShowCaseWidget state is null");
                  }
                } catch (e) {
                  AppLogger.e("Error starting showcase: $e");
                }
              });
            }

            return SingleChildScrollView(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                      child: Showcase(
                        key: ShowcaseKeys.levelBarKey,
                        title: 'Level Progress',
                        description:
                            'Track your current level and progress as you complete lessons and quizzes!',
                        targetPadding:
                            const EdgeInsets.all(4), // Adjust padding if needed
                        targetShapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                12)), // Match container shape
                        child: const LevelBarHomepage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Earth Widget with Green Curved Shapes - Now dynamically selected based on level
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/homepage_design/left.svg',
                        height: screenHeight * 0.25,
                      ),
                      // Use the correct Earth SVG based on user level
                      xpManager.isLoading
                          ? Container(
                              height: screenHeight * 0.38,
                              width: screenHeight * 0.38,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(),
                            )
                          : SvgPicture.asset(
                              _getEarthAssetPath(xpManager.currentLevel),
                              height: screenHeight * 0.38,
                            ),
                      SvgPicture.asset(
                        'assets/homepage_design/right.svg',
                        height: screenHeight * 0.25,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const StreakHomepage(),
                  ),
                  const SizedBox(height: 24),
                  // Enhanced Recent Lessons Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.book,
                          color: Colors.black,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Recent Lessons',
                          style: TextStyle(
                            fontSize: 24,
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
                  // Recent Lessons List (Non-Scrollable)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: RecentLessonsPage(),
                  ), // Ensure this widget is non-scrollable

                  // Debug controls for XP testing (remove before production release)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const XPDebugControls(),
                  ),

                  // Add some bottom padding
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
