import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const LecturesViewApp());
}

class LecturesViewApp extends StatelessWidget {
  const LecturesViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lectures View',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        fontFamily: 'Arial',
      ),
      home: const SplashScreen(),
    );
  }
}
