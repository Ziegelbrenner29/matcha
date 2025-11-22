// lib/screens/highscore_screen.dart
// ────────  KONPIRA HIGHSCORE SCREEN – 22.11.2025 LOKAL/GLOBAL TOGGLE + KOMPILIEREND!  ────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konpira/providers/settings_provider.dart';

class HighscoreScreen extends ConsumerWidget {
  const HighscoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(settingsProvider).theme;
    final bool isLocal = true; // ← später Riverpod-State für Toggle

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(theme.paperAsset),
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
          child: Column(
            children: [
              // Titel
              Padding(
                padding: const EdgeInsets.only(top: 56),
                child: Image.asset(
                  'assets/images/konpira_title.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              // Toggle Local / Global – KORREKTE PARAMETER!
              ToggleButtons(
                isSelected: [isLocal, !isLocal],
                onPressed: (index) {
                  // später: ref.read(highscoreModeProvider.notifier).state = index == 0;
                },
                borderRadius: BorderRadius.circular(30),
                fillColor: const Color(0xFF8B9F7A), // ← korrekt!
                selectedColor: Colors.white,
                color: const Color(0xFF4A3728),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12), child: Text('Lokal', style: TextStyle(fontSize: 18))),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12), child: Text('Global', style: TextStyle(fontSize: 18))),
                ],
              ),

              const SizedBox(height: 40),

              // Highscore-Tabelle
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: ListView.builder(
                      itemCount: 100,
                      itemBuilder: (context, index) {
                        final rank = index + 1;
                        return ListTile(
                          leading: Text('$rank.', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          title: Text('Spieler $rank', style: const TextStyle(fontSize: 18)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('9999', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 16),
                              Text('Zen-Meister', style: TextStyle(fontSize: 16, color: Colors.green.shade700)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}