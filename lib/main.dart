import 'package:fbla_mobile_2425_learning_app/minigames/cypher_game.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'minigames/puzzle_game.dart';
import 'pages/home.dart';
import 'pages/progress.dart';
import 'pages/learn.dart';
import 'pages/settings.dart';
import 'firebase_options.dart';
import 'pages/signin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      home: AuthWrapper(), // ✅ Check if user is logged in
    );
  }
}

// ✅ Decides whether to show Login Screen or Home Page
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator())); // Show loading
        } else if (snapshot.hasData) {
          return const MainPage(); // ✅ If user is logged in → Show Home Page
        } else {
          return SignInScreen(); // ❌ If not logged in → Show Login Screen
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
    CypherUI(subtopicId: "f51f2584-8b3b-42f2-b10c-3c47f93fbd37",)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
      ),
    );
  }
}




