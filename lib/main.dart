import 'package:fbla_mobile_2425_learning_app/minigames/cypher_game.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'pages/progress.dart';
import 'pages/learn.dart';
import 'pages/settings.dart';
import 'firebase_options.dart';
import 'pages/signin_screen.dart';
import '/security.dart';
import 'package:fbla_mobile_2425_learning_app/getkeys.dart';
import 'xp_manager.dart';
import 'package:flutter/services.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'coach_marks/showcase_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Try to initialize the API service, but continue even if it fails
    try {
      await ApiService.initialize();
    } catch (e) {
      print('Warning: Could not initialize ApiService: $e');
      // Continue with the app even if ApiService initialization fails
    }

    // Initialize Remote Config
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await remoteConfig.fetchAndActivate();

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
  final showcaseProvider = ShowcaseProvider();

  @override
  void initState() {
    super.initState();
    // Initialize the showcase provider
    showcaseProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => XPManager()),
        ChangeNotifierProvider.value(value: showcaseProvider),
      ],
      child: MaterialApp(
        title: 'FBLA Learning App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7FB069)),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        localizationsDelegates: [
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
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

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
                return const MainPage(); // ✅ User exists → Proceed
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

// ✅ Main Page (Home Page with Bottom Navigation)
class MainPage extends StatefulWidget {
  const MainPage({super.key});

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
    CypherUI(
      subject: "Math",
      grade: 1,
      unitId: 123,
      unitTitle: "Introduction to Algebra",
      subtopicId: "f51f2584-8b3b-42f2-b10c-3c47f93fbd37",
      subtopicTitle: "Basic Algebra",
      nextSubtopicId: "f51f2584-8b3b-42f2-b10c-3c47f93fbd38",
      nextSubtopicTitle: "Advanced Algebra",
      nextReadingContent: "Learn about solving equations.",
      userId: "user-456",
    )
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavBar = BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Learn',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.developer_board),
          label: 'Test Page',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
    );

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: bottomNavBar,
    );
  }
}
