// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: 'AIzaSyBru6sNxIsNF-XuoQ0Be1LCT_HmiNWBdaE',
        authDomain: 'carryhub-9acb5.firebaseapp.com',
        projectId: 'carryhub-9acb5',
        storageBucket: 'carryhub-9acb5.firebasestorage.app',
        messagingSenderId: '102040779370',
        appId: '1:102040779370:web:53ec7687951f1685282813',
        measurementId: 'G-TTBLB4XBRJ',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: 'AIzaSyBlhAE_Y8N3cmshlkHHAi-n9FfP3554HTY',
          appId: '1:102040779370:android:c1ad1cc2d20b3396282813',
          messagingSenderId: '102040779370',
          projectId: 'carryhub-9acb5',
          storageBucket: 'carryhub-9acb5.firebasestorage.app',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
