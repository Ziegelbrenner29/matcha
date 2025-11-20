// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matcha/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: MatchaApp()));
}

class MatchaApp extends StatelessWidget {
  const MatchaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matcha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF98BF8A), // Matcha-Grün
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      builder: (context, child) {
        // Fix für Android 15 / One UI 7 Overflow-Warnung (10 px unten)
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: EdgeInsets.zero,        // entfernt System-Gesten-Padding
            viewInsets: EdgeInsets.zero,     // entfernt Tastatur-Overlays etc.
          ),
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}