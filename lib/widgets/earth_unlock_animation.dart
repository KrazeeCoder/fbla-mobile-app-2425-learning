import 'dart:io';
import 'package:fbla_mobile_2425_learning_app/pages/home.dart';
import 'package:fbla_mobile_2425_learning_app/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../utils/share/achievement_image_generator.dart';
import '../linkedin_post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fbla_mobile_2425_learning_app/main.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

const MethodChannel _channel = MethodChannel('instagram_story');

Future<void> shareToInstagramStoryIOS({
  required String backgroundImagePath,
  required String stickerImagePath,
}) async {
  try {
    print("📤 Sharing to Instagram Story (iOS)");
    print("Background: $backgroundImagePath");
    print("Sticker: $stickerImagePath");

    await _channel.invokeMethod('shareToInstagramStory', {
      'backgroundImagePath': backgroundImagePath,
      'stickerImagePath': stickerImagePath,
    });
  } on PlatformException catch (e) {
    print("❌ Platform channel error: ${e.message}");
  }
}

class EarthUnlockAnimation extends StatefulWidget {
  final int newLevel;
  final String subject;
  final String subtopic;
  final int totalXP;

  const EarthUnlockAnimation(
      {required this.newLevel,
      required this.subject,
      required this.subtopic,
      required this.totalXP,
      Key? key})
      : super(key: key);

  static void show(BuildContext context, int newLevel, String subject,
      String subtopic, int totalXP) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (BuildContext context) => EarthUnlockAnimation(
          newLevel: newLevel,
          subject: subject,
          subtopic: subtopic,
          totalXP: totalXP),
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
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
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
                  _buildActionButton(
                    context,
                    icon: Icons.home_outlined,
                    label: "Home",
                    color: Colors.amber.shade600,
                    onPressed: () {
                      Navigator.of(context).pop();

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const MainPage(initialTab: 0),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

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

  Future<void> _shareToSystem(BuildContext context) async {
    print("asdf");
    try {
      final String message =
          'I just reached Level ${widget.newLevel} in the FBLA Learning App! 🎉';

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

  Future<void> _showSharePreview(BuildContext context, String message) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 20),
                          _buildSocialIcon(
                            assetPath: 'assets/Instagram_icon.png',
                            label: 'Insta Story',
                            onTap: () async {
                              Navigator.pop(context);
                              await _handleInstagramStoryShare(
                                  context, message);
                            },
                          ),
                          const SizedBox(width: 20),
                          _buildSocialIcon(
                            assetPath: 'assets/linkedin-icon.png',
                            label: 'LinkedIn',
                            onTap: () async {
                              Navigator.pop(context);
                              await _handleLinkedInShare(context, message);
                            },
                          ),
                          const SizedBox(width: 20),
                          _buildSocialIcon(
                            assetPath: 'assets/share-icon.png',
                            label: 'Share',
                            onTap: () async {
                              Navigator.pop(context);
                              await _handleImageShare(
                                  context, message, 'System');
                            },
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

  Future<String?> getLinkedInToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('linkedin_token');
  }

  Future<void> _handleLinkedInShare(
      BuildContext context, String message) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing LinkedIn share...'),
          duration: Duration(seconds: 2),
        ),
      );
      final String? token = await getLinkedInToken();
      if (token == null) {
        throw Exception('LinkedIn token not found');
      }

      final String message = generateProfessionalLinkedInPost(
        level: widget.newLevel,
        totalXP: widget.totalXP,
        subject: widget.subject,
        subtopic: widget.subtopic,
      );

      final String imagePath =
          await AchievementImageGenerator.captureAchievementImage(
        level: widget.newLevel,
        message: message,
      );

      final file = File(imagePath);
      if (!await file.exists()) throw Exception('Image not found');

      await postToLinkedIn(
        accessToken: token,
        message: message,
        context: context,
      );
    } catch (e) {
      AppLogger.e("Error sharing to LinkedIn", error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share on LinkedIn'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleImageShare(
      BuildContext context, String message, String platform) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preparing $platform share...'),
          duration: const Duration(seconds: 2),
        ),
      );

      final String imagePath =
          await AchievementImageGenerator.captureAchievementImage(
        level: widget.newLevel,
        message: message,
      );

      final file = File(imagePath);
      if (!await file.exists()) throw Exception('Image not found');

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: message,
        subject: 'FBLA Learning App Achievement',
      );
    } catch (e) {
      AppLogger.e("Error sharing to $platform", error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share on $platform'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleInstagramStoryShare(
      BuildContext context, String message) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing Instagram Story...'),
          duration: Duration(seconds: 2),
        ),
      );

      // 1. Generate the sticker image
      final String stickerImagePath =
          await AchievementImageGenerator.captureAchievementImage(
        level: widget.newLevel,
        message: message,
      );

      final stickerFile = File(stickerImagePath);
      if (!await stickerFile.exists())
        throw Exception('Generated image not found');

      // 2. Copy logo asset to a temp file to get its absolute path
      final byteData =
          await rootBundle.load('assets/branding/WorlsWiseLogo.png');
      final backgroundFile =
          File('${(await getTemporaryDirectory()).path}/temp_background.png');
      await backgroundFile.writeAsBytes(byteData.buffer.asUint8List());

      final backgroundImagePath = backgroundFile.path;

      // 3. Share using both paths
      await shareToInstagramStoryIOS(
        backgroundImagePath: backgroundImagePath,
        stickerImagePath: stickerImagePath,
      );

      AppLogger.i("Instagram Story share initiated");
    } catch (e) {
      AppLogger.e("Error sharing to Instagram Story", error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share on Instagram Story'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildSocialIcon({
    required String assetPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60, // Fixed outer size
            height: 60,
            padding: const EdgeInsets.all(10), // Padding around image
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain, // Scales the image to fit nicely
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
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
