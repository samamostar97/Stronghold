class ApiConfig{
  // For Android emulator use: http://10.0.2.2:5034
  // For iOS simulator use: http://localhost:5000
  // For Windows desktop talking to your local API: http://localhost:5000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5034',
  );
  static Uri uri(String path) => Uri.parse('$baseUrl$path');

}