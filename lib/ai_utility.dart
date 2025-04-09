import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'jsonUtility.dart';

const apiKey = "AIzaSyB6cpbKGMdZeY8p28TRRPzzkFRUzMjG_SQ";

final contentHelpModel = GenerativeModel(
  model: 'gemini-1.5-flash-latest',
  apiKey: apiKey,
);

final navigationHelpModel = GenerativeModel(
  model: 'gemini-1.5-flash-latest',
  apiKey: apiKey,
);

final safetySettings = [
  SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
  SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
  SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
  SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
];

Future<String?> generateResponseForTextContentQuestion(String text,
    String topicId, ChatSession currentChat, BuildContext context) async {
  String subtopicContent = await loadTopicContent(topicId);

  try {
    String prompt = '''
    Answer this question: $text. Here is the content for the lesson that the user is asking about $subtopicContent. Keep your response such that the relevant grade level for the topic will understand.
    Keep responses under 2 paragraphs (or more concise response if applicable) and do not repeat the content that I gave you.
    ''';
    final content = Content.text(prompt);
    final response = await currentChat.sendMessage(content);

    return response.text?.trim();
  } catch (e) {
    print("ai not working: $e");
  }
  return null;
}

Future<String> loadTopicContent(String topicId) async {
  Map<String, dynamic> data = await loadJsonData();

  for (Map subject in data["subjects"]) {
    for (Map grade in subject["grades"]) {
      for (Map unit in grade["units"]) {
        for (Map subtopic in unit["subtopics"]) {
          if (topicId == subtopic["subtopic_id"].toString()) {
            return subtopic["reading"]["content"];
          }
        }
      }
    }
  }

  return " ";
}

Future<String?> generateResponseForNavigationQuestion(
    String message, ChatSession currentChat, BuildContext context) async {
  try {
    String prompt = '''
    You are a navigation assistant for a learning app. You are given a message from the user and you need to respond with a navigation suggestion.
    Here is the message: $message

    Here is the navigation guide for the app:
    $NAVIGATION_GUIDE_PROMPT

    Answer the user's question based on the navigation guide.
    ''';
    final content = Content.text(prompt);
    final response = await currentChat.sendMessage(content);

    return response.text?.trim();
  } catch (e) {
    print("ai not working: $e");
  }
  return null;
}

const NAVIGATION_GUIDE_PROMPT = '''
# WorldWise Navigation Guide

## Main Navigation Structure
The app has five main sections accessible through the bottom navigation bar:
1. Home (🏠)
2. Learn (��)
3. Progress (📊)
4. Settings (⚙️)
5. Test Page (🛠️)

## Section Details

### 1. Home Page (🏠)
- **Level Progress Bar**: Shows your current level and XP progress
- **Earth Widget**: Displays your current level with visual representation
- **Recent Lessons**: Shows your most recently accessed lessons
- **Streak Display**: Shows your current learning streak

### 2. Learn Page (📚)
- **Two Tabs**:
  1. **Recent Lessons**: Quick access to your recently viewed lessons
  2. **Choose Your Lesson**: Browse and select new lessons
- **Subject Selection**: Choose from available subjects (Math, Science, Reading, History)
- **Grade Selection**: Select your grade level
- **Progress Tracking**: Shows completion percentage for each grade level

### 3. Progress Page (📊)
- **Streak Display**: Shows your current learning streak
- **Statistics Cards**:
  - Levels Achieved
  - Subtopics Completed
- **Subject Progress**: Detailed progress for each subject
- **Recent Activity**: Shows your recent learning activities

### 4. Settings Page (⚙️)
- **Profile Management**:
  - Profile Picture
  - First Name
  - Last Name
  - Email (read-only)
- **Progress Display**:
  - Current Level
  - Current XP
- **Preferences**:
  - Stay On Track toggle
  - Font Size adjustment
- **Tutorial**:
  - Reset App Tutorial option
- **Save Changes**: Button to save all modifications

### 5. Learning Pathway
- **Unit Structure**: Organized by units and subtopics
- **Progress Indicators**:
  - Completed lessons
  - Next available lessons
  - Locked content
- **Interactive Elements**:
  - Tap to start lessons
  - Progress tracking
  - Achievement unlocking

## Features and Interactions

### Learning Experience
1. **Lesson Structure**:
   - Reading content
   - Interactive games
   - Quizzes
   - Progress tracking

2. **Gamification Elements**:
   - XP system
   - Level progression
   - Streak tracking
   - Achievement unlocking

3. **Progress Tracking**:
   - Subject-wise progress
   - Grade-wise completion
   - Recent activity
   - Learning streak

### Navigation Tips
1. Use the bottom navigation bar to switch between main sections
2. The Home page provides a quick overview of your progress
3. The Learn page is your main hub for accessing lessons
4. Check the Progress page to track your achievements
5. Customize your experience in the Settings page

### Interactive Elements
1. **Tapping**:
   - Tap lessons to start learning
   - Tap progress indicators to view details
   - Tap settings to customize your experience

2. **Swiping**:
   - Swipe between tabs in the Learn page
   - Swipe through recent lessons

3. **Buttons**:
   - Play button to start lessons
   - Save button to apply settings
   - Reset button for tutorials

''';
