import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for ParentHero app.
///
/// These values are placeholder defaults. In production, replace with
/// your actual Firebase project configuration from the Firebase Console
/// (Project Settings > Your apps > Web / Android / iOS).
class FirebaseConfig {
  FirebaseConfig._();

  /// Firebase project ID
  static const String projectId = 'parenthero-app';

  /// Firebase Cloud Storage bucket
  static const String storageBucket = 'parenthero-app.firebasestorage.app';

  /// Firebase Web API key
  static const String apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'YOUR_API_KEY',
  );

  /// Firebase Auth domain
  static const String authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'parenthero-app.firebaseapp.com',
  );

  /// Firebase Realtime Database URL (if used)
  static const String databaseURL = String.fromEnvironment(
    'FIREBASE_DATABASE_URL',
    defaultValue: 'https://parenthero-app-default-rtdb.firebaseio.com',
  );

  /// Firebase App ID
  static const String appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:YOUR_PROJECT_NUMBER:android:YOUR_ANDROID_HASH',
  );

  /// Firebase Messaging Sender ID
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: 'YOUR_SENDER_ID',
  );

  /// Firebase Measurement ID (for Analytics)
  static const String measurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
    defaultValue: 'G-YOUR_MEASUREMENT_ID',
  );

  /// Android client ID for Google Sign-In
  static const String androidClientId = String.fromEnvironment(
    'ANDROID_CLIENT_ID',
    defaultValue: 'YOUR_ANDROID_CLIENT_ID',
  );

  /// iOS client ID for Google Sign-In
  static const String iosClientId = String.fromEnvironment(
    'IOS_CLIENT_ID',
    defaultValue: 'YOUR_IOS_CLIENT_ID',
  );

  /// Returns the [FirebaseOptions] for the current platform.
  static FirebaseOptions get currentPlatformOptions {
    if (kIsWeb) {
      return web;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    } else {
      // Fallback to web config for other platforms (macOS, Windows, Linux)
      return web;
    }
  }

  /// Web platform Firebase options
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: authDomain,
    databaseURL: databaseURL,
    storageBucket: storageBucket,
    measurementId: measurementId,
  );

  /// Android platform Firebase options
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    databaseURL: databaseURL,
    storageBucket: storageBucket,
    androidClientId: androidClientId,
  );

  /// iOS platform Firebase options
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    databaseURL: databaseURL,
    storageBucket: storageBucket,
    iosClientId: iosClientId,
    androidClientId: androidClientId,
  );
}

/// Initializes Firebase with platform-appropriate options.
///
/// Call this once in your main() before runApp().
Future<FirebaseApp> initializeFirebase() async {
  return Firebase.initializeApp(
    options: FirebaseConfig.currentPlatformOptions,
  );
}
