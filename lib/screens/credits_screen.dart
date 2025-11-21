// lib/screens/credits_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konpira/providers/settings_provider.dart';

class CreditsScreen extends ConsumerWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(settingsProvider).theme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Credits', style: TextStyle(color: Color(0xFF4A3728), fontSize: 28)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(theme.paperAsset),  // <<< LIVE WECHSEL: Paper-Textur aus Theme!
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F0E1), Color(0xFFE8DAB2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Made with ❤️ und viel Matcha',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4A3728)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Idee, Design & Code:\nZiegelbrenner29\n\n'
                  'Inspiration:\nKonpira fune fune – das echte Pilgerlied aus Shikoku\n\n'
                  'Danke an alle Teemeister, die mich zum Lachen gebracht haben! 🍵\n\n'
                  'Version 1.0 – 2025',
                  style: TextStyle(fontSize: 18, height: 1.8, color: Color(0xFF4A3728)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                Text(
                  'Namaste & いただきます！',
                  style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic, color: Color(0xFF4A3728).withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}