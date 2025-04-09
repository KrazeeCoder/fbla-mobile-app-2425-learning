import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../xp_manager.dart';

class EarthWidget extends StatefulWidget {
  const EarthWidget({super.key});

  @override
  _EarthWidgetState createState() => _EarthWidgetState();
}

class _EarthWidgetState extends State<EarthWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    // Get the current level from XPManager
    final xpManager = Provider.of<XPManager>(context);

    if (xpManager.isLoading) {
      return const CircularProgressIndicator();
    }

    return RotationTransition(
      turns: _controller,
      child: SvgPicture.asset(
        _getEarthAssetPath(xpManager.currentLevel),
      ),
    );
  }
}
