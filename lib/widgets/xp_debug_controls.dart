import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../xp_manager.dart';

/// Debug widget for testing XP and level progression
/// Only use during development, remove before final release
class XPDebugControls extends StatelessWidget {
  const XPDebugControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final xpManager = Provider.of<XPManager>(context, listen: false);

    return ExpansionTile(
      title: const Text(
        'Developer Testing Controls',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('For testing XP progression',
          style: TextStyle(fontSize: 12)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                'Current Level: ${xpManager.currentLevel}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Current XP: ${xpManager.currentXP}/${xpManager.maxXPForCurrentLevel}',
              ),
              const SizedBox(height: 12),

              // Quick XP add buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildXPButton(context, 10, Colors.green.shade200),
                  _buildXPButton(context, 50, Colors.blue.shade200),
                  _buildXPButton(context, 100, Colors.purple.shade200),
                  _buildXPButton(context, 500, Colors.orange.shade200),
                ],
              ),

              const SizedBox(height: 12),

              // Level jump buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _jumpToLevel(context, 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                    child: const Text('Level 1'),
                  ),
                  ElevatedButton(
                    onPressed: () => _jumpToLevel(context, 2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                    child: const Text('Level 2'),
                  ),
                  ElevatedButton(
                    onPressed: () => _jumpToLevel(context, 3),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                    child: const Text('Level 3'),
                  ),
                  ElevatedButton(
                    onPressed: () => _jumpToLevel(context, 4),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                    child: const Text('Level 4'),
                  ),
                  ElevatedButton(
                    onPressed: () => _jumpToLevel(context, 5),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                    child: const Text('Level 5'),
                  ),
                ],
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildXPButton(BuildContext context, int amount, Color color) {
    return ElevatedButton(
      onPressed: () => _addXP(context, amount),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Text('+$amount XP'),
    );
  }

  Future<void> _addXP(BuildContext context, int amount) async {
    final xpManager = Provider.of<XPManager>(context, listen: false);
    final levelUp = await xpManager.addXP(amount);
    if (levelUp) {
      xpManager.showLevelUpAnimation(context, xpManager.currentLevel);
    }
  }

  // This is a developer-only function to test different levels
  Future<void> _jumpToLevel(BuildContext context, int targetLevel) async {
    // This is a hacky way to force a specific level for testing
    // We directly modify the Firestore document for testing purposes
    final xpManager = Provider.of<XPManager>(context, listen: false);

    // First, determine how much XP we need
    // For demonstration, we'll use a simple formula: level * 100
    final estimatedXP = targetLevel * 100;

    // Show a snackbar indicating what we're doing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Jumping to approximately Level $targetLevel (XP: ~$estimatedXP)'),
        duration: const Duration(seconds: 1),
      ),
    );

    // Add a large amount of XP
    await xpManager.addXP(estimatedXP);

    // Refresh to ensure we're at the right level
    await xpManager.refreshXPAndLevel();
  }
}
