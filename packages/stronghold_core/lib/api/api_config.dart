/// Configurable API configuration for the shared package.
/// Each app should call [ApiConfig.initialize] before using the API.
class ApiConfig {
  static String _baseUrl = 'http://localhost:5034';

  /// Initialize the API base URL. Call this once in your app's main() before using any services.
  static void initialize(String baseUrl) {
    _baseUrl = baseUrl;
  }

  static String get baseUrl => _baseUrl;

  static Uri uri(String path) => Uri.parse('$_baseUrl$path');

  /// Build full URL for an image path (handles relative and absolute URLs)
  static String imageUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '$_baseUrl$path';
  }
}
