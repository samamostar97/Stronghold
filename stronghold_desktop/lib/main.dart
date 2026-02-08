import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'package:stronghold_desktop/screens/login_screen.dart';

void main() {
  // Initialize API base URL from environment variable (default: localhost:5034)
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5034',
  );
  ApiConfig.initialize(baseUrl);

  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stronghold Desktop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple),
        fontFamily: 'Inter',
      ),
      home: LoginScreen(),
    );
  }
}