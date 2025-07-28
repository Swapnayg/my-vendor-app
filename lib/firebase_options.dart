// File: lib/firebase_options.dart

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD-ak-MjsjBmeywCRczp9zkcfzKKLYcnh0',
    authDomain: 'my-vendor-app-9c130.firebaseapp.com',
    projectId: 'my-vendor-app-9c130',
    storageBucket: 'my-vendor-app-9c130.firebasestorage.app',
    messagingSenderId: '4281510886',
    appId: '1:4281510886:web:c5b75433af2be12ac68427',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDoDYtZfOM_4VFDh3qRFg99G9qhZ236_TM',
    appId: '1:4281510886:android:b6ad041ae4579344c68427',
    messagingSenderId: '4281510886',
    projectId: 'my-vendor-app-9c130',
    storageBucket: 'my-vendor-app-9c130.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDSuVfOgqfyfxvxnKhA9s0IXSHk1hVqcH0',
    appId: '1:4281510886:ios:cb92cc74bd47367fc68427',
    messagingSenderId: '4281510886',
    projectId: 'my-vendor-app-9c130',
    storageBucket: 'my-vendor-app-9c130.firebasestorage.app',
    iosBundleId: 'com.example.myvendorapp',
  );
}
