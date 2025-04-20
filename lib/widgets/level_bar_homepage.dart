import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/xp_service.dart';

class LevelBarHomepage extends StatelessWidget {
  const LevelBarHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access XPManager from provider
    final xpManager = Provider.of<XPService>(context);
    final theme = Theme.of(context);

    // Show loading indicator while data is loading
    if (xpManager.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Calculate XP remaining until next level
    final int currentXP = xpManager.currentXP;
    final int minXP = xpManager.minXPForCurrentLevel;
    final int maxXP = xpManager.maxXPForCurrentLevel;
    final int xpRemaining = maxXP - currentXP;

    // Calculate progress for the progress bar
    final double progressValue = xpManager.levelProgress;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF3A8C44), // Deeper green
                          Color(0xFF4CAF50), // Material green
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF3A8C44).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      "Level ${xpManager.currentLevel}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.emoji_events_outlined,
                    color: theme.colorScheme.primary.withOpacity(0.8),
                    size: 22,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  "$xpRemaining XP to level up",
                  style: TextStyle(
                    color: Color(
                        0xFF2E7D32), // Deep green that matches the level badge
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Stack(
            children: [
              // Background Container with Gradient
              Container(
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade200,
                      Colors.grey.shade100,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              // Progress Bar with Animated Gradient
              SizedBox(
                height: 14,
                child: FractionallySizedBox(
                  widthFactor: progressValue,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF4CAF50), // Material Design green
                          Color(0xFF8BC34A), // Material Design light green
                          Color(0xFF4CAF50), // Material Design green
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4CAF50).withOpacity(0.3),
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // XP Display with enhanced styling
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$currentXP XP",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF388E3C), // Material green 700
                ),
              ),
              Text(
                "$maxXP XP",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF388E3C), // Material green 700
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
