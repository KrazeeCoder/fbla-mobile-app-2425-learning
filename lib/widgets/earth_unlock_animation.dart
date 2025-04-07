import 'dart:io';
import 'package:fbla_mobile_2425_learning_app/pages/home.dart';
import 'package:fbla_mobile_2425_learning_app/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../utils/share/achievement_image_generator.dart';

/// A reusable widget that displays the Earth level-up animation
class EarthUnlockAnimation extends StatefulWidget {
  /// The new level that was achieved
  final int newLevel;

  /// Constructor
  const EarthUnlockAnimation({required this.newLevel, Key? key})
      : super(key: key);

  /// Shows the Earth unlock animation dialog
  static void show(BuildContext context, int newLevel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (BuildContext context) =>
          EarthUnlockAnimation(newLevel: newLevel),
    );
  }

  @override
  State<EarthUnlockAnimation> createState() => _EarthUnlockAnimationState();
}

class _EarthUnlockAnimationState extends State<EarthUnlockAnimation> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Earth icon
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Gradient background
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.green.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Level text
                      Text(
                        "LEVEL ${widget.newLevel}",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Unlock text
                      const Text(
                        "UNLOCKED",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Earth icon floating at the top
                Positioned(
                  top: -40,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: widget.newLevel >= 1 && widget.newLevel <= 5
                        ? SvgPicture.asset(
                            'assets/earths/${widget.newLevel}.svg',
                            width: 60,
                            height: 60,
                          )
                        : Icon(
                            Icons.public,
                            color: Colors.blue.shade600,
                            size: 60,
                          ),
                  ),
                ),
                // Stars decoration
                Positioned(
                  right: 20,
                  top: 20,
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.amber.shade300,
                    size: 24,
                  ),
                ),
                Positioned(
                  left: 30,
                  bottom: 30,
                  child: Icon(
                    Icons.star,
                    color: Colors.amber.shade200,
                    size: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Congratulations! You've unlocked Earth Level ${widget.newLevel}!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Share button
                  _buildActionButton(
                    context,
                    icon: Icons.share_outlined,
                    label: "Share",
                    color: Colors.blue.shade600,
                    onPressed: () => _shareToSystem(context),
                  ),
                  // Home button
                  _buildActionButton(
                    context,
                    icon: Icons.home_outlined,
                    label: "Home",
                    color: Colors.amber.shade600,
                    onPressed: () {
                      // Close the dialog first
                      Navigator.of(context).pop();

                      // Navigate to the MainPage (home) and clear all previous routes
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                        (route) => false, // This removes all previous routes
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Continue button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "CONTINUE",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade600,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  // Method to share achievement to system
  Future<void> _shareToSystem(BuildContext context) async {
    print("asdf");
    try {
      final String message =
          'I just reached Level ${widget.newLevel} in the FBLA Learning App! 🎉';

      // Show sharing preview dialog
      await _showSharePreview(context, message);
    } catch (e) {
      AppLogger.e("Error sharing achievement", error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Show a preview dialog before sharing
  Future<void> _showSharePreview(BuildContext context, String message) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Preview header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.share, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Share Achievement",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Preview image - this is what will be shared
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 300,
                          maxHeight: 300,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: AchievementCard(
                              level: widget.newLevel,
                              message: message,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Preview message
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),

                    // Share buttons
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Cancel button
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            child: const Text('Cancel'),
                          ),

                          // Share button
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(
                                  context); // Close the preview dialog

                              // Show loading indicator
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Generating achievement image...'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }

                              try {
                                print("asdf1");
                                // Generate the image and share it immediately
                                final String imagePath =
                                    await AchievementImageGenerator
                                        .captureAchievementImage(
                                  level: widget.newLevel,
                                  message: message,
                                );
                                print(imagePath);

                                // Check if file exists
                                final file = File(imagePath);
                                if (!await file.exists()) {
                                  throw Exception(
                                      'Generated image file not found');
                                }

                                print("asdf2");
                                final result = await Share.shareXFiles(
                                  [XFile(imagePath)],
                                  text: message,
                                  subject: 'FBLA Learning App Achievement',
                                );

                                AppLogger.i(
                                    "Shared achievement with result: ${result.status}");
                              } catch (e) {
                                AppLogger.e("Error in sharing image", error: e);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error sharing: ${e.toString()}'),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.share, size: 16),
                                SizedBox(width: 8),
                                Text('Share'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper widget for action buttons
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        elevation: MaterialStateProperty.all(2),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
