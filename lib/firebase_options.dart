// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show Firebase, FirebaseOptions;


import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


import 'firebase_options.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAjMzuMpcd6GfaImuN6O7ciQk_iT6AHgEg',
    appId: '1:205938362362:web:b41006295b93e239064643',
    messagingSenderId: '205938362362',
    projectId: 'dsom-cc8ad',
    authDomain: 'dsom-cc8ad.firebaseapp.com',
    storageBucket: 'dsom-cc8ad.appspot.com',
    measurementId: 'G-D4EKS5VZHW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-2ZpdcJaakgCBo88x9D-3CBjB1dTgvIc',
    appId: '1:205938362362:android:dfa7114f61dc7b6f064643',
    messagingSenderId: '205938362362',
    projectId: 'dsom-cc8ad',
    storageBucket: 'dsom-cc8ad.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC_wXrxBPXx6dWt6uMn7xNnYUmUXWsNdLE',
    appId: '1:205938362362:ios:63084a00ef14b858064643',
    messagingSenderId: '205938362362',
    projectId: 'dsom-cc8ad',
    storageBucket: 'dsom-cc8ad.appspot.com',
    iosClientId: '205938362362-b39mdem1udbb35an94mis20cprn8dsn5.apps.googleusercontent.com',
    iosBundleId: 'com.example.boardProject',
  );
}