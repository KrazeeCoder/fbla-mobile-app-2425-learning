# Audio System Documentation

This directory contains the audio management system for the FBLA Mobile Learning App. It provides a clean and minimalist approach to audio and haptic feedback throughout the app.

## Key Components

1. **AudioManager**: Singleton class that manages all audio playback and haptic feedback
2. **AudioAssets**: Central repository of all audio file paths
3. **AudioIntegration**: Helper class for integrating the audio system with different app components
4. **GameAudioExample**: Example class showing how to use audio in game/quiz contexts

## Minimalist Approach

This system follows a minimalist approach:
- Regular button presses use haptic feedback instead of sound
- Sound effects are reserved for significant achievements or actions
- Background music is available but can be toggled on/off

## Audio Assets

The system uses the following audio assets:
- `background_music.mp3` - Main background music
- `level_achievement.mp3` - Played when a level is completed
- `subtopic_complete.mp3` - Played when a subtopic is completed
- `game_start.mp3` - Played when starting a game
- `game_completion.mp3` - Played when completing a game
- `congrats.mp3` - Played when an earth level is unlocked

## How to Use

### Background Music

```dart
// Start the background music
await AudioManager().playBackgroundMusic();

// Pause/resume background music
await AudioManager().pauseBackgroundMusic();
await AudioManager().resumeBackgroundMusic();
```

### Haptic Feedback

```dart
// For standard button presses
AudioIntegration.handleButtonPress();

// For navigation actions
AudioIntegration.handleNavigation();
```

### Achievement Sounds

```dart
// When completing a level
await AudioIntegration.handleLevelComplete();

// When completing a subtopic
await AudioIntegration.handleSubtopicComplete();

// When completing a game
await AudioIntegration.handleGameComplete();

// When starting a game
await AudioIntegration.handleGameStart();
```

### Earth Unlock Animation

```dart
// The sound will be played automatically
EarthUnlockAnimation.show(context, newLevel, subject, subtopic, totalXP);
```

### Audio Toggle

The CustomAppBar includes a toggle button for audio that shows/hides based on audio state.

## Game Integration Example

See the `game_audio_example.dart` file for examples of how to integrate audio into games and quizzes. 