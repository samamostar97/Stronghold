import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

/// Bazni API klijent - jedina tacka komunikacije sa backendom.
/// Adresa API-ja dolazi iskljucivo preko --dart-define=API_BASE_URL.
class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

  String? _accessToken;
  String? _refreshToken;
  Future<bool>? _refreshFuture;

  /// Poziva se kad refresh ne uspije - aplikacija vraca korisnika na login.
  void Function()? onSessionExpired;

  String? get refreshToken => _refreshToken;
  bool get hasSession => _accessToken != null;

  void setTokens({required String accessToken, required String refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, {Object? body}) =>
      _send('POST', path, body: body);

  Future<dynamic> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  /// Preuzimanje binarnih fajlova (PDF/Excel izvjestaji).
  Future<List<int>> getBytes(String path) async {
    final response = await http.get(buildUri(path), headers: authHeaders());
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }
    throw ApiException(response.statusCode, _extractMessage(response));
  }

  Uri buildUri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Map<String, String> authHeaders() => {
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    bool isRetry = false,
  }) async {
    final uri = buildUri(path, query);
    final headers = {
      'Content-Type': 'application/json',
      ...authHeaders(),
    };

    late http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
        case 'POST':
          response = await http.post(uri, headers: headers, body: jsonEncode(body));
        case 'PUT':
          response = await http.put(uri, headers: headers, body: jsonEncode(body));
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
      }
    } on http.ClientException {
      throw ApiException(0, 'Server nije dostupan. Provjerite konekciju.');
    }

    // istekao access token -> jednom pokusaj refresh pa ponovi zahtjev
    if (response.statusCode == 401 && !isRetry && _refreshToken != null) {
      final refreshed = await _refresh();
      if (refreshed) {
        return _send(method, path, query: query, body: body, isRetry: true);
      }
      clearTokens();
      onSessionExpired?.call();
      throw ApiException(401, 'Sesija je istekla. Prijavite se ponovo.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    }

    throw ApiException(response.statusCode, _extractMessage(response));
  }

  /// Refresh token je jednokratan - paralelni 401 odgovori dijele isti
  /// refresh poziv da drugi ne potrosi vec iskoristeni token i izloguje korisnika.
  Future<bool> _refresh() =>
      _refreshFuture ??= _tryRefresh().whenComplete(() => _refreshFuture = null);

  Future<bool> _tryRefresh() async {
    try {
      final response = await http.post(
        buildUri('/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );
      if (response.statusCode != 200) return false;
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      setTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      return true;
    } on http.ClientException {
      return false;
    }
  }

  /// Backend poruke (poslovne i validacijske) se prosljedjuju korisniku.
  String _extractMessage(http.Response response) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (data['message'] is String) return data['message'] as String;
      if (data['errors'] is Map<String, dynamic>) {
        final errors = data['errors'] as Map<String, dynamic>;
        return errors.values
            .expand((messages) => (messages as List).cast<String>())
            .join('\n');
      }
    } on FormatException {
      // tijelo nije JSON - vrati generičku poruku ispod
    }
    return 'Došlo je do greške (${response.statusCode}). Pokušajte ponovo.';
  }
}
