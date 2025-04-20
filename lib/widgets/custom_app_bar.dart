import 'package:fbla_mobile_2425_learning_app/pages/navigation_help.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:showcaseview/showcaseview.dart';
import '../managers/coach_marks/showcase_keys.dart';
import '../managers/audio/audio_manager.dart';
import '../managers/audio/audio_integration.dart';
import '../utils/app_logger.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final AudioManager _audioManager = AudioManager();
  bool _isMusicEnabled = true;
  bool _initialized = false;

  // Animation controller for smoother icon transitions
  late AnimationController _iconAnimController;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Setup animation controller for smooth icon transition
    _iconAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconAnimation = CurvedAnimation(
      parent: _iconAnimController,
      curve: Curves.easeInOut,
    );

    // Initialize audio state - do this asynchronously
    _updateAudioState();

    // Check audio state periodically to ensure UI is in sync
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initial check after short delay to allow audio system to initialize
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _updateAudioState();
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Update audio state when app resumes to ensure UI is in sync
    if (state == AppLifecycleState.resumed && mounted) {
      _updateAudioState();
    }
  }

  @override
  void dispose() {
    _iconAnimController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _updateAudioState() {
    if (!mounted) return;

    try {
      setState(() {
        _initialized = _audioManager.isInitialized;
        _isMusicEnabled = _initialized ? _audioManager.isMusicEnabled : true;
      });

      // Sync animation controller with current state
      if (_isMusicEnabled) {
        _iconAnimController.forward();
      } else {
        _iconAnimController.reverse();
      }
    } catch (e) {
      AppLogger.e("Error updating audio state: $e");
    }
  }

  void _toggleAudio() {
    // If audio is not initialized, show a message
    if (!_audioManager.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio system is not available'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Apply haptic feedback for button press
    AudioIntegration.handleButtonPress();

    // Update UI immediately for better responsiveness
    final bool newState = !_isMusicEnabled;
    setState(() {
      _isMusicEnabled = newState;
    });

    // Animate the icon transition
    if (newState) {
      _iconAnimController.forward();
    } else {
      _iconAnimController.reverse();
    }

    // Show immediate feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newState ? 'Audio enabled' : 'Audio disabled'),
        duration: const Duration(seconds: 1),
      ),
    );

    // Process audio changes in the background
    _audioManager.toggleAllAudio().catchError((error) {
      AppLogger.e("Error toggling audio: $error");

      // If there was an error, revert the UI state
      if (mounted) {
        final bool revertedState = _audioManager.isMusicEnabled;
        setState(() {
          _isMusicEnabled = revertedState;
        });

        // Sync animation with reverted state
        if (revertedState) {
          _iconAnimController.forward();
        } else {
          _iconAnimController.reverse();
        }

        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to toggle audio'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).canvasColor,
      elevation: 0,
      title: Row(
        children: [
          Transform.translate(
            offset: const Offset(0, -1), // Subtle lift
            child: SvgPicture.asset('assets/branding/logo_and_name.svg',
                height: 55),
          ),
          const Spacer(),
          // Sound toggle button
          Showcase(
            key: ShowcaseKeys.audioIconKey,
            title: 'Sound Controls',
            description:
                'Toggle app sounds and music on or off with this button. Sound enhances your learning experience!',
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
            targetShapeBorder: const CircleBorder(),
            tooltipBorderRadius: BorderRadius.circular(10.0),
            child: IconButton(
              icon: AnimatedCrossFade(
                firstChild: const Icon(
                  Icons.volume_up,
                  color: Color(0xFF8D9A8D),
                  size: 22,
                ),
                secondChild: const Icon(
                  Icons.volume_off,
                  color: Color(0xFF8D9A8D),
                  size: 22,
                ),
                crossFadeState: _isMusicEnabled
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 200),
              ),
              onPressed: _toggleAudio,
            ),
          ),
          const SizedBox(width: 8),
          Showcase(
            key: ShowcaseKeys.helpIconKey,
            title: 'Need Help?',
            description:
                'Access helpful tips and guides about the app. Tap here anytime you need assistance with navigating WorldWise.',
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
              borderRadius: BorderRadius.circular(8.0),
            ),
            tooltipBorderRadius: BorderRadius.circular(10.0),
            child: TextButton(
              onPressed: () {
                // Apply haptic feedback for navigation
                AudioIntegration.handleNavigation();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NavigationHelpPage()),
                );
              },
              child: const Row(
                children: [
                  Text('Need Help?',
                      style: TextStyle(
                          color: Color(0xFF8D9A8D),
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.help, color: Color(0xFF8D9A8D), size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
