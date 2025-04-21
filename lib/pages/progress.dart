import 'package:fbla_mobile_2425_learning_app/services/progress_service.dart';
import 'package:fbla_mobile_2425_learning_app/widgets/recent_lessons_progress.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:showcaseview/showcaseview.dart';
import '../managers/coach_marks/showcase_keys.dart';
import '../utils/app_logger.dart';
import '../widgets/custom_app_bar.dart';
import '../managers/streak_manager.dart';
import '../widgets/leaderboard_widget.dart';

// The progress page displays user achievements, stats, and learning history
class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

// Manages progress page state and animations, using a provider to fetch data
class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  // User progress metrics
  int streak = 0;
  int level = 0;
  int subtopicsCompleted = 0;
  Map<String, dynamic> userProgress = {};
  bool _isLoading = true;

  // Animation controllers for smooth UI transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Setup fade-in animation for a polished appearance
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    fetchProgressData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Retrieves user progress metrics in parallel
  Future<void> fetchProgressData() async {
    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Fetch multiple chunks of data at same time to minimize latency
      final progressFuture = ProgressService.getUserProgress(uid);
      final subtopicsCompletedFuture =
          ProgressService.getTotalSubtopicsCompleted(uid);
      final levelDataFuture = ProgressService.calculateLevelAndPoints(uid);
      final streakFuture = StreakManager.getCurrentStreak(uid);

      // Wait for all parallel requests to complete
      final results = await Future.wait([
        progressFuture,
        subtopicsCompletedFuture,
        levelDataFuture,
        streakFuture
      ]);

      // Update state with fetched user metrics
      userProgress = results[0] as Map<String, dynamic>;
      subtopicsCompleted = results[1] as int;
      final levelData = results[2] as Map<String, dynamic>;
      level = levelData['currentLevel'];
      streak = results[3] as int;

      setState(() => _isLoading = false);
    } catch (e) {
      AppLogger.e("Error fetching progress data", error: e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color backgroundColor = Theme.of(context).canvasColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Page title with branded styling
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              'Your Progress',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          // User stats section, shows streak and achievement metrics
                          Showcase(
                            key: ShowcaseKeys.progressStatsKey,
                            title: 'Your Learning Stats',
                            description:
                                'Track your current streak and level. The longer your streak, the more points you earn!',
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
                            child: Row(
                              children: [
                                // Daily streak card
                                Expanded(
                                  flex: 2,
                                  child: _buildStreakCard(),
                                ),
                                const SizedBox(width: 12),

                                // Achievement metrics, showing level and completed subtopics
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      _StatCard(
                                        label: "Level",
                                        value: "$level",
                                        icon: Icons.star_rounded,
                                        color: Colors.amber.shade600,
                                      ),
                                      const SizedBox(height: 8),
                                      _StatCard(
                                        label: "Completed",
                                        value: "$subtopicsCompleted",
                                        icon: Icons.check_circle_rounded,
                                        color: Colors.green.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Leaderboard section, shows how user ranks against friends
                          Showcase(
                            key: ShowcaseKeys.progressLeaderboardKey,
                            title: 'Leaderboard',
                            description:
                                'See how you rank against other learners. Challenge yourself to climb the leaderboard!',
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
                            child: const LeaderboardWidget(),
                          ),
                          const SizedBox(height: 20),

                          // Recent Activity section, shows historical data
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Activity',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Recent Lessons section, shows recent lessons completed
                          Container(
                            height:
                                400, // Added fixed height for recent lessons section
                            child: Showcase(
                              key: ShowcaseKeys.progressRecentActivityKey,
                              title: 'Recent Activity',
                              description:
                                  'View your learning history here. See what lessons you\'ve completed and where you left off.',
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
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: RecentLessonsTabWidget(
                                    userProgress: userProgress,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20), // Added bottom padding
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildStreakCard() {
    final Color streakColor = Colors.deepOrange.shade400;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: streakColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: streakColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Current Streak',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$streak',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: streakColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'days',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Keep it up!',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// Stat card, shows a label and value with an icon
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Card styling with consistent visual cues for different stats
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Colored icon badge for visual identification
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          // Emphasize value with larger font than label for hierarchy
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
