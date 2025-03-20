import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/earth_widget.dart';
import '../widgets/lessons.dart';
import '../widgets/level_bar_homepage.dart';
import '../widgets/recent_lessons_homepage.dart';
import '../widgets/streak_homepage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // Get the screen height using MediaQuery
    final screenHeight = MediaQuery.of(context).size.height;

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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const LevelBarHomepage(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Earth Widget with Green Curved Shapes
            Stack(
              alignment: Alignment.center,
              children: [
                // Green Curved Shape on the Left
                Positioned(
                  left: -screenHeight * 0.01, // Adjust position
                  child: ClipPath(
                    clipper: _CurvedShapeClipper(),
                    child: Container(
                      width: screenHeight * 0.2, // Adjust size
                      height: screenHeight * 0.35, // Match Earth height
                      color: Colors.green.withOpacity(0.3), // Subtle green
                    ),
                  ),
                ),
                // Green Curved Shape on the Right
                Positioned(
                  right: -screenHeight * 0.1, // Adjust position
                  child: ClipPath(
                    clipper: _CurvedShapeClipper(),
                    child: Container(
                      width: screenHeight * 0.2, // Adjust size
                      height: screenHeight * 0.35, // Match Earth height
                      color: Colors.green.withOpacity(0.3), // Subtle green
                    ),
                  ),
                ),
                // Earth Widget
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: screenHeight * 0.35, // Adjust EarthWidget height
                    child: SvgPicture.asset('assets/earths/4.svg'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const StreakHomepage(),
            ),
            const SizedBox(height: 24),
            // Enhanced Recent Lessons Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          ],
        ),
      ),
    );
  }
}

class _CurvedShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.5); // Start at the middle-left

    // First curve: Gradual curve upwards
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.3, // Control point (closer to start)
      size.width * 0.5, size.height * 0.5, // End point (middle)
    );

    // Second curve: Gradual curve downwards
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.7, // Control point (closer to end)
      size.width, size.height * 0.5, // End at the middle-right
    );

    // Close the path
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}