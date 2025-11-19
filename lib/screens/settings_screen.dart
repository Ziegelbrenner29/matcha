// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Einstellungen',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
        ),
      ),
      body: const Center(
        child: Text(
          'Einstellungen\n(wird bald wunderschön ☺)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, color: Colors.grey),
        ),
      ),
    );
  }
}