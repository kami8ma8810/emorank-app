import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// デフォルトのFirebase設定を提供するクラス
///
/// 実際の環境では、FirebaseコンソールからダウンロードされたFirebaseOptionsを使用します
/// ここではダミーデータを使用して開発を可能にします
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ダミーデータ - 実際のアプリでは各プラットフォーム用のFirebaseコンソールから取得した値を使用します
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:123456789012:web:abc123def456ghi789',
    messagingSenderId: '123456789012',
    projectId: 'emorank-app',
    authDomain: 'emorank-app.firebaseapp.com',
    storageBucket: 'emorank-app.appspot.com',
    measurementId: 'G-MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:123456789012:android:abc123def456ghi789',
    messagingSenderId: '123456789012',
    projectId: 'emorank-app',
    storageBucket: 'emorank-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:123456789012:ios:abc123def456ghi789',
    messagingSenderId: '123456789012',
    projectId: 'emorank-app',
    storageBucket: 'emorank-app.appspot.com',
    iosClientId: 'ios-client-id',
    iosBundleId: 'com.emorank.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:123456789012:macos:abc123def456ghi789',
    messagingSenderId: '123456789012',
    projectId: 'emorank-app',
    storageBucket: 'emorank-app.appspot.com',
    iosClientId: 'macos-client-id',
    iosBundleId: 'com.emorank.app',
  );
}
