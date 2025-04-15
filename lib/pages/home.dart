import 'package:fbla_mobile_2425_learning_app/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/level_bar_homepage.dart';
import '../widgets/recent_lessons_homepage.dart';
import '../widgets/streak_homepage.dart';
import '../widgets/xp_debug_controls.dart';
import '../xp_manager.dart';
import '../coach_marks/showcase_keys.dart';
import '../coach_marks/showcase_provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fbla_mobile_2425_learning_app/pages/recent_lessons_homepage_UI.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showcaseTriggered = false;
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
    final showcaseProvider =
        Provider.of<ShowcaseProvider>(context, listen: false);
    final currentLevel = xpManager.currentLevel;

    return Scaffold(
      appBar: CustomAppBar(),
      body: ShowCaseWidget(
        onStart: (index, key) =>
            AppLogger.i("Showcase started with index: $index"),
        onComplete: (index, key) {
          if (index == null) {
            AppLogger.i("Showcase completed");
            showcaseProvider.markShowcaseComplete();
          }
        },
        builder: (context) => Builder(
          builder: (builderContext) {
            if (!_showcaseTriggered) {
              _showcaseTriggered = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  final showCaseState = ShowCaseWidget.of(builderContext);
                  showCaseState?.startShowCase([ShowcaseKeys.levelBarKey]);
                } catch (e) {
                  AppLogger.e("Error starting showcase: $e");
                }
              });
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        targetPadding: const EdgeInsets.all(4),
                        targetShapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const LevelBarHomepage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  xpManager.isLoading
                      ? Center(
                          child: Container(
                            height: screenHeight * 0.38,
                            width: screenHeight * 0.38,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            final List<String> earthImages = List.generate(
                              5,
                              (index) => _getEarthAssetPath(index + 1),
                            );

                            final PageController _pageController =
                                PageController(
                              initialPage: currentLevel - 1,
                              viewportFraction: 0.6,
                            );

                            return SizedBox(
                              height: screenHeight * 0.4,
                              width: screenWidth,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: earthImages.length,
                                itemBuilder: (context, index) {
                                  final isLocked = (index + 1) > currentLevel;

                                  return AnimatedBuilder(
                                    animation: _pageController,
                                    builder: (context, child) {
                                      double value = 1.0;
                                      if (_pageController
                                          .position.haveDimensions) {
                                        value = (_pageController.page! - index)
                                            .abs();
                                        value = (1.2 - (value * 0.5))
                                            .clamp(0.6, 1.2);
                                      }

                                      return Center(
                                        child: Transform.scale(
                                          scale: value,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              isLocked
                                                  ? Container(
                                                      height:
                                                          screenHeight * 0.32,
                                                      width:
                                                          screenHeight * 0.32,
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.grey,
                                                      ),
                                                    )
                                                  : SvgPicture.asset(
                                                      earthImages[index],
                                                      height:
                                                          screenHeight * 0.35,
                                                      width:
                                                          screenHeight * 0.35,
                                                      fit: BoxFit.contain,
                                                    ),
                                              if (isLocked)
                                                const Icon(
                                                  Icons.lock,
                                                  color: Colors.white,
                                                  size: 44,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: StreakHomepage(userId: user?.uid ?? ''),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.book, color: Colors.black, size: 28),
                        SizedBox(width: 8),
                        Text(
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      height: 130, // or slightly less if needed
                      child: RecentLessonsUIPage(latestOnly: true),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const XPDebugControls(),
                  ),
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
