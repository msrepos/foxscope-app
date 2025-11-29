import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:foxscope/core/constants/app_env.dart';
import 'package:foxscope/core/utils/result.dart';
import 'package:foxscope/core/utils/string_set.dart';
import 'package:http/http.dart' as http;
import 'models/scope.dart';

class ScopesRepository {
  Future<Result<List<Scope>>> fetchScopes() async {
    final url = Uri.parse("${AppEnv.apiBaseUrl}/scope");

    debugPrint("ScopesRepository.fetchScopes ----> Request: $url");

    try {
      final response = await http.get(url);

      debugPrint(
        "ScopesRepository.fetchScopes ----> Response: "
            "statusCode: ${response.statusCode}, "
            "body: ${response.body}",
      );

      if (response.statusCode == 200) {
        List<Scope>? scopes = ScopeMapper().fromJsonArray(response.body);
        debugPrint(
          "ScopesRepository.fetchScopes ----> DecodedScopes: ${scopes?.length}-items"
        );
        return Result(scopes);
      }
      //
      else {
        return Result(
          null,
          message: StringSet("No scopes found"),
        );
      }
    } catch (e) {
      debugPrint("ScopesRepository.fetchScopes ----> EXCEPTION: $e");
      return Result(null, message: StringSet("Error: $e"));
    }
  }
}
