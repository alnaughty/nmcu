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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBh4yXC6JDjJyqc6u74KjSAVIACDC1Io0g',
    appId: '1:660278184036:android:00509e40dd83d89181f771',
    messagingSenderId: '660278184036',
    projectId: 'nomnomdelivery-5cbaa',
    storageBucket: 'nomnomdelivery-5cbaa.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD8gFgNtEGKQm0mLUElxw3b7iwL2fDhS_o',
    appId: '1:660278184036:ios:cd23b39d1afb9cb381f771',
    messagingSenderId: '660278184036',
    projectId: 'nomnomdelivery-5cbaa',
    storageBucket: 'nomnomdelivery-5cbaa.firebasestorage.app',
    androidClientId: '660278184036-5dgoji6eb7pd49t4qcq4la5m75m422kt.apps.googleusercontent.com',
    iosClientId: '660278184036-k6p7sv0iaeb92ra82trl0cthcmu3k7af.apps.googleusercontent.com',
    iosBundleId: 'com.nomnomapp.nomnom',
  );
}