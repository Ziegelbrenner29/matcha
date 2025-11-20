// lib/screens/credits_screen.dart
import 'package:flutter/material.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Credits')),
      body: const Center(child: Text('Made with ❤️ und viel Tee')),
    );
  }
}