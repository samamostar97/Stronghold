import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/gym_visit_dto.dart';
import 'token_storage.dart';
import 'api_helper.dart';

/// API service for gym visit operations (check-in, check-out, current visitors).
/// Uses static methods following the pattern of other services in this app.
class GymVisitsApi {
  /// Fetches all visitors currently in the gym (not checked out yet).
  /// Returns a list of CurrentVisitorDTO.
  static Future<List<CurrentVisitorDTO>> getCurrentVisitors() async {
    final token = await TokenStorage.accessToken();

    final response = await http.get(
      ApiConfig.uri('/api/admin/visits/current-users-list'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => CurrentVisitorDTO.fromJson(j)).toList();
    }
    throw Exception(extractErrorMessage(response));
  }

  /// Checks in a user by their userId.
  /// Returns the new visitor record.
  static Future<CurrentVisitorDTO> checkIn(int userId) async {
    final token = await TokenStorage.accessToken();

    final response = await http.post(
      ApiConfig.uri('/api/admin/visits/check-in'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'userId': userId}),
    );

    if (response.statusCode == 201) {
      return CurrentVisitorDTO.fromJson(json.decode(response.body));
    }
    throw Exception(extractErrorMessage(response));
  }

  /// Checks out a visitor by their visitId.
  /// Returns nothing on success (204 No Content).
  static Future<void> checkOut(int visitId) async {
    final token = await TokenStorage.accessToken();

    final response = await http.post(
      ApiConfig.uri('/api/admin/visits/check-out/$visitId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      return; // Success
    }
    throw Exception(extractErrorMessage(response));
  }
}
