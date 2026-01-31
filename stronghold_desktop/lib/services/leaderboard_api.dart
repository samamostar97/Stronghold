import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/leaderboard_dto.dart';
import 'token_storage.dart';
import 'api_helper.dart';

class LeaderboardApi {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.accessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<LeaderboardEntryDTO>> getLeaderboard() async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/leaderboard'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final List<dynamic> json = jsonDecode(res.body) as List<dynamic>;
      return json
          .map((item) => LeaderboardEntryDTO.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(extractErrorMessage(res));
  }
}
