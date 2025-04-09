import 'package:flutter/material.dart';
import 'navigation_chatbot.dart';

class NavigationHelpPage extends StatefulWidget {
  const NavigationHelpPage({Key? key}) : super(key: key);

  @override
  _NavigationHelpPageState createState() => _NavigationHelpPageState();
}

class _NavigationHelpPageState extends State<NavigationHelpPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Help'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.help_outline),
              text: 'Guide',
            ),
            Tab(
              icon: Icon(Icons.chat_bubble_outline),
              text: 'Ask Assistant',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Guide Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  'Main Navigation',
                  'The app has five main sections accessible through the bottom navigation bar:',
                  [
                    '🏠 Home - Your dashboard with progress and recent lessons',
                    '📚 Learn - Access lessons and learning materials',
                    '📊 Progress - Track your achievements and statistics',
                    '⚙️ Settings - Customize your app experience',
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Learning Journey',
                  'How to navigate through lessons:',
                  [
                    '1. Go to the Learn tab',
                    '2. Choose your subject and grade level',
                    '3. Select a lesson to start learning',
                    '4. Complete lessons to earn XP and level up',
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Quick Tips',
                  'Navigation shortcuts:',
                  [
                    '• Swipe between tabs in the Learn page',
                    '• Tap progress indicators to view details',
                    '• Use the bottom navigation bar to switch sections',
                    '• Check your streak on the Home page',
                  ],
                ),
              ],
            ),
          ),

          // Chat Assistant Tab
          const NavigationChatbot(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String description, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
