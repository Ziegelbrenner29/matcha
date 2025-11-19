// lib/widgets/chawan_widget.dart
import 'package:flutter/material.dart';

class ChawanWidget extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onLongPressGrab;

  const ChawanWidget({
    super.key,
    required this.onTap,
    required this.onLongPressGrab,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: (_) => onLongPressGrab(),
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF5F0E9), // zartes Porzellan-Beige
          border: Border.all(color: const Color(0xFF98BF8A), width: 8), // Matcha-Grün-Rand
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Chawan',
            style: TextStyle(fontSize: 32, color: Color(0xFF555555), fontWeight: FontWeight.w300),
          ),
        ),
      ),
    );
  }
}