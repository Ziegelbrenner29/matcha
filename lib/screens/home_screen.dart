// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:matcha/screens/game_screen.dart';
import 'package:matcha/core/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F0E1), Color(0xFFE8DAB2)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Matcha',
                style: TextStyle(fontSize: 72, fontFamily: 'Zen', color: Color(0xFF4A3728)),
              ),
              const SizedBox(height: 80),
              _buildVariantButton(context, 'Konpira fune fune', 'konpira'),
              const SizedBox(height: 40),
              _buildVariantButton(context, 'Matcha pon!', 'matchapon'),
              const SizedBox(height: 80),
              Text(
                '1,99 € · Einmalkauf · Keine Werbung · Pures Zen',
                style: TextStyle(color: Colors.brown[600], fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVariantButton(BuildContext context, String title, String variant) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFBC9F7A),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GameScreen(variant: variant)),
        );
      },
      child: Text(title, style: const TextStyle(fontSize: 28, color: Colors.white)),
    );
  }
}