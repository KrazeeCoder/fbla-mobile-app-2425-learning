# WorldWise: Interactive Learning Platform 🌍📚

<div align="center">
  <img src="assets/branding/WorlsWiseLogo.png" alt="WorldWise Logo" width="200"/>
  <br>
  <p><i>Empowering global learning through interactive educational experiences</i></p>
</div>

[![Flutter Version](https://img.shields.io/badge/Flutter-^3.5.0-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Integrated-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📱 Overview

WorldWise is a cutting-edge mobile learning platform designed to transform educational experiences. The app combines interactive learning modules, progress tracking, personalized learning pathways, and AI-powered assistance to create an engaging and effective learning environment.

### 🌟 Key Features

- **Interactive Learning Modules**: Engaging educational content across various subjects
- **Personalized Learning Pathways**: Customized learning journeys based on user progress and preferences
- **Progress Tracking**: Visual representation of learning achievements and milestones
- **Earth Growth System**: Unique level progression visualized through an evolving Earth avatar
- **AI-Powered Chatbot Assistant**: Intelligent support for learning questions
- **Offline Learning Support**: Access educational content without internet connection
- **Multi-Platform Compatibility**: Available on iOS, Android, and web platforms

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.5.0)
- Dart SDK (^3.0.0)
- Firebase project setup
- Android Studio / Xcode for mobile deployment

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/fbla-mobile-app-2425-learning.git
   cd fbla-mobile-app-2425-learning
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add iOS and Android apps to your Firebase project
   - Download and add configuration files:
     - For Android: Place `google-services.json` in `android/app/`
     - For iOS: Place `GoogleService-Info.plist` in `ios/Runner/`

4. **Run the application**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

WorldWise is built using a robust architectural pattern with the following components:

### 📂 Project Structure

```
lib/
├── main.dart            # App entry point
├── firebase_options.dart # Firebase configuration
├── models/              # Data models
├── pages/               # App screens
│   ├── home.dart        # Home screen
│   ├── learn.dart       # Learning modules
│   ├── learn_pathway.dart # Learning pathways
│   ├── progress.dart    # Progress tracking
│   └── ...
├── services/            # Business logic services
├── utils/               # Utility functions
├── widgets/             # Reusable UI components
└── managers/            # State management
```

### 🔧 Technologies Used

- **Frontend**: Flutter, Dart
- **Backend**: Firebase (Authentication, Firestore, Storage, Remote Config)
- **AI Integration**: Google Generative AI for chatbot functionality
- **Audio**: Just Audio and Audioplayers for interactive audio content
- **Security**: Encryption services for data protection
- **Analytics**: Firebase Analytics for usage metrics

## 🔐 Authentication and Security

WorldWise implements secure authentication through Firebase with multiple sign-in options:
- Email/Password authentication
- Google account integration
- Apple ID sign-in
- LinkedIn authentication

Data encryption is handled by our custom EncryptionService to ensure user data remains secure.

## 🌐 Learning Ecosystem

### Subject Areas

The platform covers various educational subjects including:
- Mathematics
- English/Language Arts
- Science
- History/Social Studies
- And more!

### Learning Formats

Content is delivered through diverse formats:
- Interactive lessons
- Mini-games
- Quizzes
- Visual learning aids
- Audio content

## 📊 Progress Tracking System

WorldWise features a comprehensive progress tracking system:

- **XP System**: Earn experience points for completed activities
- **Earth Avatar**: Watch your Earth grow and evolve as you progress
- **Level Progression**: Unlock new content and features as you level up
- **Streak Tracking**: Build and maintain learning streaks for consistent engagement
- **Visual Statistics**: View detailed breakdowns of your learning journey

## 🧩 Minigames & Interactive Elements

The app includes various minigames to reinforce learning:
- Vocabulary challenges
- Mathematical puzzles
- Scientific experiments
- Historical quests

## 🎯 Future Roadmap

- **Community Features**: Connect with other learners
- **Content Creation Tools**: Allow educators to create custom content
- **Expanded Subject Areas**: Additional educational topics
- **Advanced Analytics**: More detailed learning insights
- **AR Integration**: Augmented reality learning experiences

## 🤝 Contributing

We welcome contributions to WorldWise! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact & Support

- **Website**: [worldwise.education](https://worldwise.education)
- **Email**: support@worldwise.education
- **Twitter**: [@WorldWiseApp](https://twitter.com/WorldWiseApp)

---

<div align="center">
  <p>Made with ❤️ by the WorldWise Team</p>
  <p>© 2023-2024 WorldWise Learning, Inc. All rights reserved.</p>
</div>
