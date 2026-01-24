import 'dart:convert';
import 'package:http/http.dart' as http;

/// Extracts the error message from API response
/// Returns the 'error' field from JSON if available, otherwise a generic message
String extractErrorMessage(http.Response res) {
  try {
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return json['error'] ?? 'Greška: ${res.statusCode}';
  } catch (_) {
    return 'Greška: ${res.statusCode}';
  }
}
