import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Flutter Web
    if (kIsWeb) {
      if (kDebugMode) {
        // 本地 flutter run -d chrome
        return 'http://127.0.0.1:8080';
      }

      // 生产 Web
      // nginx 代理 /api -> 8080
      return '';
    }

    // Android / iOS
    return 'https://xx.example.com';
  }
}