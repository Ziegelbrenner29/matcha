// lib/widgets/zen_background.dart (neu anlegen)
import 'package:flutter/material.dart';

class ZenBackground extends StatelessWidget {
  const ZenBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F0E1), Color(0xFFE8DAB2)],
        ),
      ),
    );
  }
}