// Beispiel – lib/screens/game_variant1_screen.dart
import 'package:flutter/material.dart';

class GameVariant1Screen extends StatelessWidget {
  const GameVariant1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Zen-Modus\nkommt bald…',
          style: TextStyle(fontSize: 24, color: Colors.grey[600]),
        ),
      ),
    );
  }
}