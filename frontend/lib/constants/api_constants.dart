import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else {
      // return 'http://10.0.2.2:8080';
      return 'http://192.168.56.48:8080';
    }
  }

  static const String health = '/actuator/health';
  static const String auth = '/api/auth';
  static const String users = '/api/users';
  static const String exams = '/api/exams';
}
