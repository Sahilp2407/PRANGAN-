import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for Prangan housing society platform.
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
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBeJ9ATzpn_uTFsuJ8hmuvcWOlPp3SmXSU',
    appId: '1:693521991053:web:9a84c257cd37f3a5be29c4',
    messagingSenderId: '693521991053',
    projectId: 'prangan-e2aa1',
    authDomain: 'prangan-e2aa1.firebaseapp.com',
    storageBucket: 'prangan-e2aa1.firebasestorage.app',
    measurementId: 'G-JP0GM24QTG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBeJ9ATzpn_uTFsuJ8hmuvcWOlPp3SmXSU',
    appId: '1:693521991053:android:9a84c257cd37f3a5be29c4',
    messagingSenderId: '693521991053',
    projectId: 'prangan-e2aa1',
    storageBucket: 'prangan-e2aa1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBeJ9ATzpn_uTFsuJ8hmuvcWOlPp3SmXSU',
    appId: '1:693521991053:ios:9a84c257cd37f3a5be29c4',
    messagingSenderId: '693521991053',
    projectId: 'prangan-e2aa1',
    storageBucket: 'prangan-e2aa1.firebasestorage.app',
    iosBundleId: 'com.prangan.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBeJ9ATzpn_uTFsuJ8hmuvcWOlPp3SmXSU',
    appId: '1:693521991053:ios:9a84c257cd37f3a5be29c4',
    messagingSenderId: '693521991053',
    projectId: 'prangan-e2aa1',
    storageBucket: 'prangan-e2aa1.firebasestorage.app',
    iosBundleId: 'com.prangan.app',
  );
}
