import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

/// Widget that displays a shareable achievement card
class AchievementCard extends StatelessWidget {
  /// The level achieved
  final int level;

  /// Achievement message
  final String message;

  /// Constructor
  const AchievementCard({
    required this.level,
    required this.message,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      height: 800,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App name at the top
          const Text(
            "FBLA LEARNING APP",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Earth icon
          Container(
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 0,
                )
              ],
            ),
            child: level >= 1 && level <= 5
                ? SvgPicture.asset(
                    'assets/earths/$level.svg',
                    width: 120,
                    height: 120,
                  )
                : Icon(
                    Icons.public,
                    color: Colors.blue.shade600,
                    size: 120,
                  ),
          ),
          const SizedBox(height: 40),
          // Level number
          Text(
            "LEVEL $level",
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          // Unlocked text
          const Text(
            "UNLOCKED",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 40),
          // Achievement message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Utility for generating shareable achievement images
class AchievementImageGenerator {
  /// Screenshot controller for capturing widgets
  static final ScreenshotController _screenshotController =
      ScreenshotController();

  /// Captures a widget as an image and saves it to a temporary file
  static Future<String> captureAchievementImage({
    required int level,
    required String message,
  }) async {
    // Get the temporary directory
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/achievement_level_$level.png';

    try {
      // Create the achievement card widget
      final widget = AchievementCard(
        level: level,
        message: message,
      );

      // Capture the widget as an image with higher quality
      final Uint8List? bytes = await _screenshotController.captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 200),
        pixelRatio: 1.5,
        targetSize: const Size(800, 800),
      );

      if (bytes != null) {
        // Save the image to a file
        final file = File(imagePath);
        await file.writeAsBytes(bytes);
        return imagePath;
      } else {
        throw Exception("Failed to capture image - bytes are null");
      }
    } catch (e) {
      debugPrint('Error capturing widget as image: $e');
      // Fallback to creating a simple image if widget capture fails
      await _createFallbackImage(imagePath, level);
    }

    return imagePath;
  }

  /// Creates a simple fallback image
  static Future<void> _createFallbackImage(String path, int level) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(700, 700);

    // Draw a gradient background
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        [Colors.blue.shade700, Colors.green.shade600],
      );

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Add text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'LEVEL $level\nUNLOCKED!',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 60,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2),
    );

    // Convert to an image
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final file = File(path);
    await file.writeAsBytes(buffer);
  }
}
