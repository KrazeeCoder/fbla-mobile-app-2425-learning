import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'managers/coach_marks/showcase_keys.dart';
import 'pages/home.dart';
import 'pages/progress.dart';
import 'pages/learn.dart';
import 'pages/settings.dart';
import 'firebase_options.dart';
import 'pages/signin_screen.dart';
import 'utils/security.dart';
import 'package:fbla_mobile_2425_learning_app/services/encryption_service.dart';
import 'services/xp_service.dart';
import 'package:flutter/services.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'managers/coach_marks/showcase_provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:fbla_mobile_2425_learning_app/utils/app_logger.dart';
import 'services/settings_service.dart';
import 'managers/audio/audio_integration.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  AppLogger.i("WidgetsFlutterBinding initialized successfully");

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Try to initialize the API service, but continue even if it fails
    try {
      await EncryptionService.initialize();
    } catch (e) {
      print('Warning: Could not initialize EncryptionService: $e');
      // Continue with the app even if EncryptionService initialization fails
    }

    AppLogger.i("Firebase initialized successfully");

    // Initialize Remote Config
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await remoteConfig.fetchAndActivate();
    AppLogger.i("Remote config fetched and activated");

    // Initialize audio system in background to prevent UI blocking
    // Don't await this operation - let it complete asynchronously
    Future.delayed(Duration.zero, () {
      _initializeAudioWithTimeout();
    });

    // Continue with app startup regardless of audio initialization
    runApp(const MyApp());
  } catch (e) {
    print('Fatal error during app initialization: $e');
    // You might want to show an error screen here instead
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app: $e'),
        ),
      ),
    ));
  }
}

// Initialize audio with a timeout to prevent hanging
Future<void> _initializeAudioWithTimeout() async {
  try {
    // Add a timeout to prevent hanging
    await AudioIntegration.initialize().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        AppLogger.w("Audio initialization timed out after 5 seconds");
        throw TimeoutException("Audio initialization timed out");
      },
    );
    AppLogger.i("Audio system initialized successfully");
  } catch (e) {
    AppLogger.e(
        "Error initializing audio system, continuing without audio: $e");
    // Audio will be disabled but app will continue running
  }
}

Map<String, Map> allLessons = {
  "math": {
    "grade 1": 85,
    "grade 2": 75,
    "grade 3": 90,
    "grade 4": 95,
    "grade 5": 80
  },
  "english": {
    "grade 1": 67,
    "grade 2": 56,
    "grade 3": 90,
    "grade 4": 76,
    "grade 5": 75
  },
  "science": {
    "grade 1": 68,
    "grade 2": 98,
    "grade 3": 56,
    "grade 4": 96,
    "grade 5": 85
  },
  "history": {
    "grade 1": 80,
    "grade 2": 70,
    "grade 3": 82,
    "grade 4": 98,
    "grade 5": 87
  }
};

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final showcaseService = ShowcaseService();
  bool _showcaseTriggered = false;

  @override
  void initState() {
    super.initState();
    // Initialize the showcase service
    showcaseService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => XPService()),
        ChangeNotifierProvider.value(value: showcaseService),
        ChangeNotifierProvider(create: (_) => SettingsService()),
      ],
      child: MaterialApp(
        title: 'WorldWise',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7FB069)),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
        ],
      ),
    );
  }
}

// ✅ Decides whether to show Login Screen or Home Page
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showcaseTriggered = false;

  // 🆕 Helper function to build the FAB
  FloatingActionWidget _buildShowcaseFab(BuildContext context) {
    return FloatingActionWidget(
      child: Stack(
        children: [
          Positioned(
            top: 40, // Adjust as needed for spacing below notch/status bar
            left: 16,
            child: Material(
              elevation: 4,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    ShowCaseWidget.of(context).dismiss();
                    Provider.of<ShowcaseService>(context, listen: false)
                        .markShowcaseComplete();
                    AppLogger.i("Showcase skipped");
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.skip_next_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "Skip",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> checkUserStillExists(User user) async {
    try {
      await user.reload(); // Tries to get fresh data from Firebase
      if (FirebaseAuth.instance.currentUser == null) {
        return false;
      }
      return true;
    } catch (e) {
      // Handles cases like user deleted manually or invalid token
      if (e is FirebaseAuthException &&
          (e.code == 'user-not-found' || e.code == 'invalid-user-token')) {
        await FirebaseAuth.instance.signOut();
        return false;
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: checkUserStillExists(snapshot.data!),
            builder: (context, existenceSnapshot) {
              if (existenceSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }

              if (existenceSnapshot.hasData && existenceSnapshot.data == true) {
                setLoginUserKeys(snapshot.data!);
                return ShowCaseWidget(
                  onStart: (index, key) {
                    AppLogger.i("Showcase started with index: $index");
                  },
                  onComplete: (index, key) {
                    if (index == null) {
                      AppLogger.i("Showcase completed");
                      Provider.of<ShowcaseService>(context, listen: false)
                          .markShowcaseComplete();
                    }
                  },
                  // 🆕 Assign the FAB builder function with explicit cast
                  globalFloatingActionWidget:
                      _buildShowcaseFab as FloatingActionBuilderCallback?,
                  builder: (context) => Builder(
                    builder: (builderContext) {
                      // Use a Builder to get the correct context that has access to ShowCaseWidget
                      if (!_showcaseTriggered) {
                        _showcaseTriggered = true;
                        // Delay to ensure all widgets are properly laid out
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          AppLogger.i("Attempting to start showcase");
                          try {
                            final showcaseService =
                                Provider.of<ShowcaseService>(builderContext,
                                    listen: false);
                            if (!showcaseService.hasCompletedInitialShowcase) {
                              // Use safer approach that handles errors gracefully
                              showcaseService
                                  .startHomeScreenShowcase(builderContext);
                              AppLogger.i("Showcase requested successfully");
                            }
                          } catch (e) {
                            AppLogger.e("Error requesting showcase: $e");
                          }
                        });
                      }

                      return const MainPage();
                    },
                  ),
                );
              } else {
                return SignInScreen(); // ❌ User deleted → Go to sign-in
              }
            },
          );
        } else {
          return SignInScreen(); // ❌ No logged-in user
        }
      },
    );
  }
}

// ✅ Main Page (Pages with Bottom Navigation)
class MainPage extends StatefulWidget {
  final int initialTab;
  const MainPage({super.key, this.initialTab = 0});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    LearnPage(),
    ProgressPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      AppLogger.i("Selected index: $_selectedIndex");

      // If navigating to home tab (index 0), check if we need to complete the tutorial
      if (index == 0) {
        AppLogger.i("Navigating to home tab");
        // Check if the tutorial is flagged as ready to complete
        final showcaseService =
            Provider.of<ShowcaseService>(context, listen: false);
        if (showcaseService.completeTutorialPending) {
          // Complete the tutorial when returning to home screen
          showcaseService.checkAndCompleteTutorial();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavBar = BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Showcase(
            key: ShowcaseKeys.homeNavKey,
            title: 'Home Tab',
            description:
                'Return to the main home screen with all your learning stats and recent lessons.',
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
            targetPadding:
                EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 25),
            targetShapeBorder: const CircleBorder(),
            tooltipBorderRadius: BorderRadius.circular(10.0),
            child: const Icon(Icons.home),
            onTargetClick: () {
              _onItemTapped(0);
            },
            disposeOnTap: true,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Showcase(
            key: ShowcaseKeys.learnNavKey,
            title: 'Learn Tab',
            description:
                'Tap here to explore new lessons and subjects. This is where your learning journey begins!',
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
            targetPadding:
                EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 25),
            targetShapeBorder: const CircleBorder(),
            tooltipBorderRadius: BorderRadius.circular(10.0),
            child: const Icon(Icons.menu_book),
            onTargetClick: () {
              _onItemTapped(1);
              final showcaseService =
                  Provider.of<ShowcaseService>(context, listen: false);
              if (!showcaseService.hasCompletedInitialShowcase) {
                showcaseService.startLearnScreenShowcase(context);
              }
            },
            disposeOnTap: true,
          ),
          label: 'Learn',
        ),
        BottomNavigationBarItem(
          icon: Showcase(
            key: ShowcaseKeys.progressNavKey,
            title: 'Progress Tab',
            description:
                'Monitor your learning journey! View your activity streaks, achievements, and completed lessons here.',
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
            targetPadding:
                EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 25),
            targetShapeBorder: const CircleBorder(),
            tooltipBorderRadius: BorderRadius.circular(10.0),
            child: const Icon(Icons.bar_chart),
            onTargetClick: () {
              _onItemTapped(2);
              final showcaseService =
                  Provider.of<ShowcaseService>(context, listen: false);
              if (!showcaseService.hasCompletedInitialShowcase) {
                showcaseService.startProgressScreenShowcase(context);
              }
            },
            disposeOnTap: true,
          ),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Showcase(
            key: ShowcaseKeys.settingsNavKey,
            title: 'Settings Tab',
            description:
                'Personalize your learning experience! Adjust app settings, manage your profile, and customize preferences here.',
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
            targetPadding:
                EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 25),
            targetShapeBorder: const CircleBorder(),
            tooltipBorderRadius: BorderRadius.circular(10.0),
            child: const Icon(Icons.settings),
            onTargetClick: () {
              _onItemTapped(3);
              final showcaseService =
                  Provider.of<ShowcaseService>(context, listen: false);
              if (!showcaseService.hasCompletedInitialShowcase) {
                showcaseService.startSettingsScreenShowcase(context);
              }
            },
            disposeOnTap: true,
          ),
          label: 'Settings',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Color(0xFF0D47A1),
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed, // Ensure labels are always visible
    );

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: bottomNavBar,
    );
  }
}
