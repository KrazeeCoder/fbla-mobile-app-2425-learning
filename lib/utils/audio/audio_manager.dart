import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_assets.dart';
import '../app_logger.dart';
import 'dart:async';

/// Manages all audio in the application including background music and sound effects.
/// Uses a singleton pattern to ensure only one instance exists throughout the app.
class AudioManager {
  // Singleton instance
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // Audio players
  AudioPlayer? _backgroundMusicPlayer;
  AudioPlayer? _soundEffectPlayer;

  // Track initialization state
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Settings
  bool _isMusicEnabled = true;
  bool _isSoundEffectsEnabled = true;
  double _musicVolume = 0.5;
  double _soundEffectsVolume = 0.7;
  bool _isHapticFeedbackEnabled = true;

  // Getters
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEffectsEnabled => _isSoundEffectsEnabled;
  bool get isHapticFeedbackEnabled => _isHapticFeedbackEnabled;
  double get musicVolume => _musicVolume;
  double get soundEffectsVolume => _soundEffectsVolume;

  /// Initialize the audio manager and load saved preferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Create audio players with a timeout
      await Future(() async {
        _backgroundMusicPlayer = AudioPlayer();
        _soundEffectPlayer = AudioPlayer();
      }).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          AppLogger.w("Audio player creation timed out");
          throw TimeoutException("Audio player creation timed out");
        },
      );

      await _loadPreferences();

      // Set initial volumes
      _backgroundMusicPlayer?.setVolume(_isMusicEnabled ? _musicVolume : 0);
      _soundEffectPlayer
          ?.setVolume(_isSoundEffectsEnabled ? _soundEffectsVolume : 0);

      // Loop background music by default with a timeout
      await Future(() async {
        _backgroundMusicPlayer?.setLoopMode(LoopMode.all);
      }).timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          AppLogger.w("Setting loop mode timed out");
          return;
        },
      );

      _isInitialized = true;
    } catch (e) {
      AppLogger.e('Error initializing AudioManager', error: e);

      // Clean up on initialization failure
      _backgroundMusicPlayer?.dispose();
      _soundEffectPlayer?.dispose();
      _backgroundMusicPlayer = null;
      _soundEffectPlayer = null;
      _isInitialized = false;

      // Re-throw to allow caller to handle the error
      rethrow;
    }
  }

  /// Load audio preferences from shared preferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMusicEnabled = prefs.getBool('isMusicEnabled') ?? true;
      _isSoundEffectsEnabled = prefs.getBool('isSoundEffectsEnabled') ?? true;
      _isHapticFeedbackEnabled =
          prefs.getBool('isHapticFeedbackEnabled') ?? true;
      _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
      _soundEffectsVolume = prefs.getDouble('soundEffectsVolume') ?? 0.7;
    } catch (e) {
      AppLogger.e('Error loading audio preferences', error: e);
      // Use defaults if preferences can't be loaded
    }
  }

  /// Save audio preferences to shared preferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isMusicEnabled', _isMusicEnabled);
      await prefs.setBool('isSoundEffectsEnabled', _isSoundEffectsEnabled);
      await prefs.setBool('isHapticFeedbackEnabled', _isHapticFeedbackEnabled);
      await prefs.setDouble('musicVolume', _musicVolume);
      await prefs.setDouble('soundEffectsVolume', _soundEffectsVolume);
    } catch (e) {
      AppLogger.e('Error saving audio preferences', error: e);
    }
  }

  /// Play background music
  /// [assetPath] defaults to the main background music if not specified
  Future<void> playBackgroundMusic({String? assetPath}) async {
    if (!_isInitialized || !_isMusicEnabled || _backgroundMusicPlayer == null)
      return;

    try {
      final musicPath = assetPath ?? AudioAssets.backgroundMusic;

      // Stop current music if playing
      if (_backgroundMusicPlayer!.playing) {
        await _backgroundMusicPlayer!.stop().timeout(
          const Duration(seconds: 1),
          onTimeout: () {
            AppLogger.w("Stop background music timed out");
            return;
          },
        );
      }

      // Set asset with timeout
      await _backgroundMusicPlayer!.setAsset(musicPath).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          AppLogger.w("Setting music asset timed out: $musicPath");
          throw TimeoutException("Setting music asset timed out");
        },
      );

      // Play with timeout
      await _backgroundMusicPlayer!.play().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          AppLogger.w("Playing music timed out");
          throw TimeoutException("Playing music timed out");
        },
      );
    } catch (e) {
      AppLogger.e('Error playing background music', error: e);
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    if (!_isInitialized || _backgroundMusicPlayer == null) return;

    try {
      if (_backgroundMusicPlayer!.playing) {
        await _backgroundMusicPlayer!.stop();
      }
    } catch (e) {
      AppLogger.e('Error stopping background music', error: e);
    }
  }

  /// Pause background music
  Future<void> pauseBackgroundMusic() async {
    if (!_isInitialized || _backgroundMusicPlayer == null) return;

    try {
      if (_backgroundMusicPlayer!.playing) {
        await _backgroundMusicPlayer!.pause();
      }
    } catch (e) {
      AppLogger.e('Error pausing background music', error: e);
    }
  }

  /// Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (!_isInitialized || !_isMusicEnabled || _backgroundMusicPlayer == null)
      return;

    try {
      if (!_backgroundMusicPlayer!.playing) {
        await _backgroundMusicPlayer!.play();
      }
    } catch (e) {
      AppLogger.e('Error resuming background music', error: e);
    }
  }

  /// Play a sound effect
  Future<void> playSoundEffect(String assetPath) async {
    if (!_isInitialized ||
        !_isSoundEffectsEnabled ||
        _soundEffectPlayer == null) return;

    try {
      // Set asset with timeout
      await _soundEffectPlayer!.setAsset(assetPath).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          AppLogger.w("Setting sound effect asset timed out: $assetPath");
          throw TimeoutException("Setting sound effect timed out");
        },
      );

      // Play with timeout
      await _soundEffectPlayer!.play().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          AppLogger.w("Playing sound effect timed out");
          throw TimeoutException("Playing sound effect timed out");
        },
      );
    } catch (e) {
      AppLogger.e('Error playing sound effect', error: e);
    }
  }

  /// Play haptic feedback for standard button presses
  void playButtonFeedback() {
    if (!_isInitialized || !_isHapticFeedbackEnabled) return;

    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      AppLogger.e('Error playing haptic feedback', error: e);
    }
  }

  /// Play haptic feedback for a successful action
  void playSuccessFeedback() {
    if (!_isInitialized || !_isHapticFeedbackEnabled) return;

    try {
      HapticFeedback.mediumImpact();
    } catch (e) {
      AppLogger.e('Error playing success haptic feedback', error: e);
    }
  }

  /// Play sound for level completion
  Future<void> playLevelCompleteSound() async {
    if (!_isInitialized) return;

    await playSoundEffect(AudioAssets.levelComplete);
    playSuccessFeedback();
  }

  /// Play sound for subtopic completion
  Future<void> playSubtopicCompleteSound() async {
    if (!_isInitialized) return;

    await playSoundEffect(AudioAssets.subtopicComplete);
    playSuccessFeedback();
  }

  /// Play sound for game completion
  Future<void> playGameCompleteSound() async {
    if (!_isInitialized) return;

    await playSoundEffect(AudioAssets.gameComplete);
    playSuccessFeedback();
  }

  /// Play sound for earth unlock
  Future<void> playEarthUnlockedSound() async {
    if (!_isInitialized) return;

    await playSoundEffect(AudioAssets.levelComplete);
    playSuccessFeedback();
  }

  /// Play sound for game start
  Future<void> playGameStartSound() async {
    if (!_isInitialized) return;

    await playSoundEffect(AudioAssets.gameStart);
  }

  /// Toggle background music on/off
  Future<void> toggleMusicEnabled() async {
    if (!_isInitialized) return;

    _isMusicEnabled = !_isMusicEnabled;

    if (_isMusicEnabled && _backgroundMusicPlayer != null) {
      _backgroundMusicPlayer!.setVolume(_musicVolume);
      await resumeBackgroundMusic();
    } else if (_backgroundMusicPlayer != null) {
      _backgroundMusicPlayer!.setVolume(0);
      await pauseBackgroundMusic();
    }

    await _savePreferences();
  }

  /// Toggle sound effects on/off
  Future<void> toggleSoundEffectsEnabled() async {
    if (!_isInitialized) return;

    _isSoundEffectsEnabled = !_isSoundEffectsEnabled;
    if (_soundEffectPlayer != null) {
      _soundEffectPlayer!
          .setVolume(_isSoundEffectsEnabled ? _soundEffectsVolume : 0);
    }
    await _savePreferences();
  }

  /// Toggle haptic feedback on/off
  Future<void> toggleHapticFeedbackEnabled() async {
    if (!_isInitialized) return;

    _isHapticFeedbackEnabled = !_isHapticFeedbackEnabled;
    await _savePreferences();
  }

  /// Toggle all audio on/off
  Future<void> toggleAllAudio() async {
    if (!_isInitialized) {
      AppLogger.w("Cannot toggle audio: Audio system not initialized");
      return;
    }

    // Toggle the state
    _isMusicEnabled = !_isMusicEnabled;
    _isSoundEffectsEnabled = _isMusicEnabled;

    // Save preferences asynchronously without awaiting
    _savePreferences().catchError((e) {
      AppLogger.e("Error saving audio preferences: $e");
    });

    // Handle background music player without awaiting each operation
    if (_isMusicEnabled && _backgroundMusicPlayer != null) {
      AppLogger.i("Enabling background music");
      _backgroundMusicPlayer!.setVolume(_musicVolume * 0.8);

      // If not already playing, start playback
      if (!(_backgroundMusicPlayer!.playing)) {
        AppLogger.i("Starting background music playback");
        // Don't await this - let it happen in the background
        playBackgroundMusic().catchError((e) {
          AppLogger.e("Failed to play background music on toggle: $e");
        });
      } else {
        AppLogger.i("Background music already playing, adjusting volume");
      }
    } else if (_backgroundMusicPlayer != null) {
      AppLogger.i("Disabling background music");
      _backgroundMusicPlayer!.setVolume(0);
      // Don't await this - let it happen in the background
      pauseBackgroundMusic().catchError((e) {
        AppLogger.e("Failed to pause background music on toggle: $e");
      });
    }

    // Handle sound effect player volume
    if (_soundEffectPlayer != null) {
      AppLogger.i(
          "Setting sound effect volume: ${_isSoundEffectsEnabled ? _soundEffectsVolume : 0}");
      _soundEffectPlayer!
          .setVolume(_isSoundEffectsEnabled ? _soundEffectsVolume : 0);
    }
  }

  /// Set music volume
  Future<void> setMusicVolume(double volume) async {
    if (!_isInitialized) return;

    _musicVolume = volume.clamp(0.0, 1.0);
    if (_isMusicEnabled && _backgroundMusicPlayer != null) {
      _backgroundMusicPlayer!.setVolume(_musicVolume);
    }
    await _savePreferences();
  }

  /// Set sound effects volume
  Future<void> setSoundEffectsVolume(double volume) async {
    if (!_isInitialized) return;

    _soundEffectsVolume = volume.clamp(0.0, 1.0);
    if (_isSoundEffectsEnabled && _soundEffectPlayer != null) {
      _soundEffectPlayer!.setVolume(_soundEffectsVolume);
    }
    await _savePreferences();
  }

  /// Dispose audio players when no longer needed
  void dispose() {
    if (!_isInitialized) return;

    _backgroundMusicPlayer?.dispose();
    _soundEffectPlayer?.dispose();
    _backgroundMusicPlayer = null;
    _soundEffectPlayer = null;
    _isInitialized = false;
  }
}
