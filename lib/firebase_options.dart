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
    apiKey: 'AIzaSyC8LUIh6Z8091kzkaSW_d3xebM6ddJlZCY',
    appId: '1:557579110628:web:26e87dd79c0a38359b04f1',
    messagingSenderId: '557579110628',
    projectId: 'siar-e30b2',
    authDomain: 'siar-e30b2.firebaseapp.com',
    databaseURL: 'https://siar-e30b2-default-rtdb.firebaseio.com',
    storageBucket: 'siar-e30b2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAeg2elHuS95uE5BqGV9kApKQ1Rbo_0ydM',
    appId: '1:557579110628:android:47e95329ed0992cf9b04f1',
    messagingSenderId: '557579110628',
    projectId: 'siar-e30b2',
    databaseURL: 'https://siar-e30b2-default-rtdb.firebaseio.com',
    storageBucket: 'siar-e30b2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDeFIbFZXYwvoS5LcDU6O37buv3cySHAvo',
    appId: '1:557579110628:ios:b5df89c5513f71d99b04f1',
    messagingSenderId: '557579110628',
    projectId: 'siar-e30b2',
    databaseURL: 'https://siar-e30b2-default-rtdb.firebaseio.com',
    storageBucket: 'siar-e30b2.firebasestorage.app',
    androidClientId: '557579110628-3b8ul9eir3sjaql5adfqkg77v18v5j1f.apps.googleusercontent.com',
    iosClientId: '557579110628-4ueku6n8pmvsnir5rvrtd5tb0skmg8pj.apps.googleusercontent.com',
    iosBundleId: 'com.example.siar',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDeFIbFZXYwvoS5LcDU6O37buv3cySHAvo',
    appId: '1:557579110628:ios:b5df89c5513f71d99b04f1',
    messagingSenderId: '557579110628',
    projectId: 'siar-e30b2',
    databaseURL: 'https://siar-e30b2-default-rtdb.firebaseio.com',
    storageBucket: 'siar-e30b2.firebasestorage.app',
    androidClientId: '557579110628-3b8ul9eir3sjaql5adfqkg77v18v5j1f.apps.googleusercontent.com',
    iosClientId: '557579110628-4ueku6n8pmvsnir5rvrtd5tb0skmg8pj.apps.googleusercontent.com',
    iosBundleId: 'com.example.siar',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC8LUIh6Z8091kzkaSW_d3xebM6ddJlZCY',
    appId: '1:557579110628:web:45d18709fbb1cc659b04f1',
    messagingSenderId: '557579110628',
    projectId: 'siar-e30b2',
    authDomain: 'siar-e30b2.firebaseapp.com',
    databaseURL: 'https://siar-e30b2-default-rtdb.firebaseio.com',
    storageBucket: 'siar-e30b2.firebasestorage.app',
  );

}