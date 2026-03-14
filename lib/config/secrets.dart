import 'package:flutter_dotenv/flutter_dotenv.dart';

class Secrets {
  static String get firebaseApiKeyBrowser =>
      dotenv.env['API_KEY_BROWSER'] ?? '';
  static String get firebaseApiKeyAndroid =>
      dotenv.env['API_KEY_ANDROID'] ?? '';
  static String get firebaseApiKeyIos => dotenv.env['API_KEY_IOS'] ?? '';
  static String get firebaseApiKeyMacos => dotenv.env['API_KEY_MACOS'] ?? '';
  static String get firebaseApiKeyWindows =>
      dotenv.env['API_KEY_WINDOWS'] ?? '';
}
