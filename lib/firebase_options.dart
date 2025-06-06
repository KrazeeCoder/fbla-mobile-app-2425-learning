// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCZuSTzLpKlQYRXodb-znTJjM6LHqyag28',
    appId: '1:381062391055:web:21104e80e249cc62178a7a',
    messagingSenderId: '381062391055',
    projectId: 'fbla-learning-app-2425',
    authDomain: 'fbla-learning-app-2425.firebaseapp.com',
    storageBucket: 'fbla-learning-app-2425.firebasestorage.app',
    measurementId: 'G-6FD53NV617',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdbfvfwyH7VP26j8TGyQX8kg968ItVnb8',
    appId: '1:381062391055:android:2998224fceeeb263178a7a',
    messagingSenderId: '381062391055',
    projectId: 'fbla-learning-app-2425',
    storageBucket: 'fbla-learning-app-2425.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCwVqJ21EgYomoTP0PFMU__ZuqOynG2lAc',
    appId: '1:381062391055:ios:1af94d3e0bf5ff91178a7a',
    messagingSenderId: '381062391055',
    projectId: 'fbla-learning-app-2425',
    storageBucket: 'fbla-learning-app-2425.firebasestorage.app',
    iosBundleId: 'com.example.fblaMobile2425LearningApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCwVqJ21EgYomoTP0PFMU__ZuqOynG2lAc',
    appId: '1:381062391055:ios:1af94d3e0bf5ff91178a7a',
    messagingSenderId: '381062391055',
    projectId: 'fbla-learning-app-2425',
    storageBucket: 'fbla-learning-app-2425.firebasestorage.app',
    iosBundleId: 'com.example.fblaMobile2425LearningApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCZuSTzLpKlQYRXodb-znTJjM6LHqyag28',
    appId: '1:381062391055:web:0bcbdc34c99a418c178a7a',
    messagingSenderId: '381062391055',
    projectId: 'fbla-learning-app-2425',
    authDomain: 'fbla-learning-app-2425.firebaseapp.com',
    storageBucket: 'fbla-learning-app-2425.firebasestorage.app',
    measurementId: 'G-CMQ8W9GNSE',
  );

}