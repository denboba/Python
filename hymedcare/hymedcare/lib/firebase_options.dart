import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCsSqrH_sFm3Ge-NdFK2CkD8LASGRrFlfU',
    appId: '1:163853510633:web:0092d3e7a82f7530068d78',
    messagingSenderId: '163853510633',
    projectId: 'hymedcare-9615f',
    authDomain: 'hymedcare-9615f.firebaseapp.com',
    databaseURL: 'https://hymedcare-9615f-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'hymedcare-9615f.firebasestorage.app',
    measurementId: 'G-FPQ39H4PZV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDNaYIftcsCMKDavdSvJIYk0GW47ooOpSE',
    appId: '1:163853510633:android:330a7d8a3b0fd7e2068d78',
    messagingSenderId: '163853510633',
    projectId: 'hymedcare-9615f',
    databaseURL: 'https://hymedcare-9615f-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'hymedcare-9615f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD6143xzFS3dYSX6WkbCMa6oAn0Q6ocxXI',
    appId: '1:163853510633:ios:d82d1f3ed8af19fe068d78',
    messagingSenderId: '163853510633',
    projectId: 'hymedcare-9615f',
    databaseURL: 'https://hymedcare-9615f-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'hymedcare-9615f.firebasestorage.app',
    iosClientId: '163853510633-21misct868bj5l3ng121rls8rhgh9kr1.apps.googleusercontent.com',
    iosBundleId: 'com.example.hymedcare',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD6143xzFS3dYSX6WkbCMa6oAn0Q6ocxXI',
    appId: '1:163853510633:ios:d82d1f3ed8af19fe068d78',
    messagingSenderId: '163853510633',
    projectId: 'hymedcare-9615f',
    databaseURL: 'https://hymedcare-9615f-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'hymedcare-9615f.firebasestorage.app',
    iosClientId: '163853510633-21misct868bj5l3ng121rls8rhgh9kr1.apps.googleusercontent.com',
    iosBundleId: 'com.example.hymedcare',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCsSqrH_sFm3Ge-NdFK2CkD8LASGRrFlfU',
    appId: '1:163853510633:web:0092d3e7a82f7530068d78',
    messagingSenderId: '163853510633',
    projectId: 'hymedcare-9615f',
    authDomain: 'hymedcare-9615f.firebaseapp.com',
    databaseURL: 'https://hymedcare-9615f-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'hymedcare-9615f.firebasestorage.app',
    measurementId: 'G-FPQ39H4PZV',
  );

}