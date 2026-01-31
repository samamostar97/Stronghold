import 'package:flutter/material.dart';
import 'package:stronghold_desktop/screens/login_screen.dart';

void main(){
  runApp(const App());
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
          seedColor: Colors.deepPurple)
      ),
      home: LoginScreen(),
    );
  }
}