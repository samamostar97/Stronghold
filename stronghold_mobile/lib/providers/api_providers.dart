import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';

/// API client provider using shared core package
/// Used by all mobile services for HTTP requests
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Note: TokenStorage uses static methods, so no provider needed
// Use TokenStorage.accessToken(), TokenStorage.saveLogin(), TokenStorage.clear() directly
