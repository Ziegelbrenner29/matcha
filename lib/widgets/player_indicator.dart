// lib/widgets/player_indicator.dart
import 'package:flutter/material.dart';

class PlayerIndicator extends StatelessWidget {
  final bool isActive;

  const PlayerIndicator({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: isActive ? const Color(0xFF98BF8A) : Colors.grey[300]!,
          width: isActive ? 6 : 3,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF98BF8A).withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 8,
                )
              ]
            : null,
      ),
    );
  }
}