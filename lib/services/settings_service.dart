import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _stayOnTrack = false;
  double _fontSize = 14.0; // Default font size
  bool _isLoading = true;

  // Getters
  bool get stayOnTrack => _stayOnTrack;
  double get fontSize => _fontSize;
  bool get isLoading => _isLoading;

  SettingsService() {
    loadSettings();
  }

  // Load settings from Firestore
  Future<void> loadSettings() async {
    final user = _auth.currentUser;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final settings = doc['settings'] ?? {};

      _stayOnTrack = settings['stayOnTrack'] ?? false;
      _fontSize = (settings['fontSize'] ?? 14).toDouble();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update font size
  Future<void> updateFontSize(double size) async {
    _fontSize = size;
    notifyListeners();
    await _saveSettings();
  }

  // Update stay on track
  Future<void> updateStayOnTrack(bool value) async {
    _stayOnTrack = value;
    notifyListeners();
    await _saveSettings();
  }

  // Save settings to Firestore
  Future<void> _saveSettings() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'settings.stayOnTrack': _stayOnTrack,
        'settings.fontSize': _fontSize,
      });
    } catch (e) {
      print('Error saving settings: $e');
    }
  }
}
