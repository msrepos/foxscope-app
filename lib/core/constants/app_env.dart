import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  /// For API routes (api.php)
  static String get apiBaseUrl {
    return dotenv.env["API_BASE_URL"] ?? "http://localhost:8000/api";
  }

  /// For web routes (web.php)
  static String get webBaseUrl {
    return dotenv.env["WEB_BASE_URL"] ?? "http://localhost:8000";
  }
}
