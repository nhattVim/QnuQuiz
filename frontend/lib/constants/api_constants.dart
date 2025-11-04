import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    } else {
      return 'http://192.168.1.134:8080';
    }
  }

  static const String health = '/actuator/health';
  static const String users = '/users';
  static const String auth = '/api/auth';
}
