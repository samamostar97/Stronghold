import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/gym_visit_dto.dart';
import 'token_storage.dart';

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
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else {
      throw Exception('Failed to load visitors: ${response.statusCode}');
    }
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
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else if (response.statusCode == 409) {
      // User already checked in - extract error message from response
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'User is already checked in');
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Invalid user ID');
    } else {
      throw Exception('Check-in failed: ${response.statusCode}');
    }
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
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else if (response.statusCode == 400 || response.statusCode == 409 || response.statusCode == 404) {
      try {
        final error = json.decode(response.body);
        // Try to get the most specific error message
        final errorMessage = error['detail'] ??
                           error['message'] ??
                           error['error'] ??
                           'Check-out failed (${response.statusCode})';
        throw Exception(errorMessage);
      } catch (e) {
        // If JSON parsing fails, use the raw response body or generic message
        if (response.body.isNotEmpty) {
          throw Exception(response.body);
        }
        throw Exception('Check-out failed (${response.statusCode})');
      }
    } else {
      // For other errors, try to parse response body
      try {
        final error = json.decode(response.body);
        final errorMessage = error['detail'] ??
                           error['message'] ??
                           error['error'] ??
                           'Check-out failed (${response.statusCode})';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Check-out failed: ${response.statusCode}');
      }
    }
  }
}
