import 'dart:io';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class VivahFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) {
      return android;
    } else {
      return ios;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTGcDzwZCJU_jtPzj5VVHc9IDFyLj0is4',
    appId: '1:349131421979:android:1cfec52d9a5e5f4ba97bbe',
    messagingSenderId: '349131421979',
    projectId: 'vivah-sambandh',
    storageBucket: 'vivah-sambandh.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCTGcDzwZCJU_jtPzj5VVHc9IDFyLj0is4',
    appId: '1:349131421979:ios:1cfec52d9a5e5f4ba97bbe',
    messagingSenderId: '349131421979',
    projectId: 'vivah-sambandh',
    storageBucket: 'vivah-sambandh.firebasestorage.app',
  );
}
