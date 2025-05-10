import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiUrl =>
      dotenv.env['API_URL'] ?? 'https://srv797850.hstgr.cloud';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? '/api';
  static String get authToken => dotenv.env['AUTH_TOKEN'] ?? '';

  static String get baseApiUrl => '$apiUrl$apiVersion';
}
