import 'dart:convert';

import 'package:foxscope/core/constants/app_env.dart';
import 'package:foxscope/core/utils/account_storage.dart';
import 'package:foxscope/core/utils/result.dart';
import 'package:foxscope/core/utils/string_set.dart';
import 'package:foxscope/features/auth/data/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  Future<Result<User>> login({
    required String username,
    required String password,
    IAccountStorage<User>? userStorage,
  }) async {
    final url = Uri.parse("${AppEnv.apiBaseUrl}/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": username.trim(),
          "password": password.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["token"] != null) {
        final token = data["token"];
        final userId = data["user"]["id"];

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('user_name', data['user']['name']);
        prefs.setString('token', token);

        final user = UserMapper().fromMap({
          'token': token,
          'userId': userId,
          'userName': data['user']['name'],
        });
        (userStorage ?? AccountStorage(UserMapper())).saveAccount(
          user,
          username.trim(),
          password.trim(),
        );
        //.saveUserNameAndPassword(username.trim(), password.trim(),);

        return Result(user);
      }
      //
      else {
        return Result(
          null,
          message: StringSet(data["message"] ?? "Login failed"),
        );
      }
    } catch (e) {
      return Result(null, message: StringSet("Error: $e"));
    }
  }
}
