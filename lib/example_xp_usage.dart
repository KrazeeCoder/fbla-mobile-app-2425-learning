import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'xp_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Example widget showing how to use XPManager in your app
class XPExample extends StatelessWidget {
  const XPExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the XPManager through Provider
    final xpManager = Provider.of<XPManager>(context);

    // UI shows current level and XP
    return Column(
      children: [
        // Display current level
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.stars_rounded,
                color: Colors.deepPurple.shade400,
                size: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${xpManager.currentLevel}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Progress to next level indicator
                    LinearProgressIndicator(
                      value: xpManager.levelProgress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.deepPurple.shade300,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${xpManager.currentXP} / ${xpManager.maxXPForCurrentLevel} XP',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Example buttons to add XP
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => _addXPWithAnimation(context, xpManager, 10),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Add 10 XP'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _addXPWithAnimation(context, xpManager, 50),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Add 50 XP'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _addXPWithAnimation(context, xpManager, 100),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Add 100 XP'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Method to add XP and show animation if level up occurs
  Future<void> _addXPWithAnimation(
      BuildContext context, XPManager xpManager, int xpAmount) async {
    // Show a simple XP earned animation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('+ $xpAmount XP earned!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );

    // Add XP and check if level up occurred
    final leveledUp = await xpManager.addXP(
      xpAmount,
      onLevelUp: (newLevel) {
        // Show level up animation
        xpManager.showLevelUpAnimation(context, newLevel);
      },
    );

    // If no level up, just refresh the data
    if (!leveledUp) {
      await xpManager.refreshXPAndLevel();
    }
  }
}

// Example of how to set up XPManager with Provider
class XPManagerSetupExample extends StatelessWidget {
  const XPManagerSetupExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => XPManager(),
      child: MaterialApp(
        title: 'XP Manager Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('XP System Example'),
          ),
          body: const Center(
            child: XPExample(),
          ),
        ),
      ),
    );
  }
}

// Integration with existing progress tracking
void awardXPForCompletedActivity(BuildContext context) {
  // Get current user
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // Access XPManager through Provider
  final xpManager = Provider.of<XPManager>(context, listen: false);

  // Award XP based on activity type
  // Example:
  xpManager.addXP(50, onLevelUp: (newLevel) {
    // Show level up animation if user leveled up
    xpManager.showLevelUpAnimation(context, newLevel);
  });
}

// Example of how to call this from your subtopic widget when content is completed
void onSubtopicCompleted(BuildContext context) async {
  // 1. First, update progress using your existing methods
  // await markSubtopicAsCompleted(...);
  // await updateResumePoint(...);

  // 2. Then award XP using the XPManager
  awardXPForCompletedActivity(context);

  // 3. Continue with navigation or other actions
  // Navigator.push(...);
}
