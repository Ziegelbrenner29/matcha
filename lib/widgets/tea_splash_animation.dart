// lib/widgets/tea_splash_animation.dart
import 'package:flutter/material.dart';

class TeaSplashAnimation extends StatelessWidget {
  final String winner;
  final VoidCallback onAnimationComplete;

  const TeaSplashAnimation({super.key, required this.winner, required this.onAnimationComplete});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), onAnimationComplete);

    return Container(
      color: Colors.white.withOpacity(0.95),
      child: Center(
        child: Text(
          winner,
          style: const TextStyle(fontSize: 42, color: Color(0xFF98BF8A), fontWeight: FontWeight.w300),
        ),
      ),
    );
  }
}