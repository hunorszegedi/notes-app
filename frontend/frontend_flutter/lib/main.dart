import 'package:flutter/material.dart';
import 'screens/splash.dart';
import './styles/app_styles.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppStyle.darkTheme,
      home: const SplashScreen(),
    );
  }
}
