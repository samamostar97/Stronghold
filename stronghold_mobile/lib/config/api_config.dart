class ApiConfig {
  // For Android emulator use: http://10.0.2.2:5034
  // For iOS simulator use: http://localhost:5034
  // For physical device use your machine's IP: http://192.168.x.x:5034
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5034',
  );

  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}
