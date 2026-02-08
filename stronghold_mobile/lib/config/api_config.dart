import 'package:stronghold_core/stronghold_core.dart' as core;

/// Legacy ApiConfig that delegates to the shared package
/// Used by old services until they are converted to use providers
class ApiConfig {
  static String get baseUrl => core.ApiConfig.baseUrl;

  static Uri uri(String path) => core.ApiConfig.uri(path);
}
