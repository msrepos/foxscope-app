import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String get apiBaseUrl {
    return dotenv.env["API_BASE_URL"] ?? "http://localhost:8000";
  }
}
