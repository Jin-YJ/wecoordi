// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAVC9jKc-_MYaBZ4S78bVLIDyCUxHJ9VR0',
    appId: '1:14960927041:web:7519efb3ad93a0fcb0c1c0',
    messagingSenderId: '14960927041',
    projectId: 'wecoordi',
    authDomain: 'wecoordi.firebaseapp.com',
    storageBucket: 'wecoordi.appspot.com',
    measurementId: 'G-GQ1DG6ZZ69',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB2kWJNIIsXbzxE-asqxv5IbrnBNX-9fH4',
    appId: '1:14960927041:android:c811221ddad3bc08b0c1c0',
    messagingSenderId: '14960927041',
    projectId: 'wecoordi',
    storageBucket: 'wecoordi.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyADQ4oCYT4qRO8MVJ2xGsyQQNXFnjfo_5Y',
    appId: '1:14960927041:ios:c39a400c189d0fdeb0c1c0',
    messagingSenderId: '14960927041',
    projectId: 'wecoordi',
    storageBucket: 'wecoordi.appspot.com',
    iosClientId: '14960927041-qpdn3m5hro8pchlam5emv5s0l1171f1m.apps.googleusercontent.com',
    iosBundleId: 'com.example.wecoordi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyADQ4oCYT4qRO8MVJ2xGsyQQNXFnjfo_5Y',
    appId: '1:14960927041:ios:71d3d8db68b598a5b0c1c0',
    messagingSenderId: '14960927041',
    projectId: 'wecoordi',
    storageBucket: 'wecoordi.appspot.com',
    iosClientId: '14960927041-b2m6b5vrt0ns9tj90narim5k21gq82ru.apps.googleusercontent.com',
    iosBundleId: 'com.example.wecoordi.RunnerTests',
  );
}