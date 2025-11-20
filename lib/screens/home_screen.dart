// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matcha/screens/game_variant1_screen.dart';
import 'package:matcha/screens/game_variant2_screen.dart';
import 'package:matcha/screens/settings_screen.dart';
import 'package:matcha/screens/tea_ceremony_info_screen.dart';
import 'package:matcha/screens/credits_screen.dart';

// Provider für den aktuell gewählten Modus (Variante 1 oder 2)
final selectedVariantProvider = StateProvider<int>((ref) => 2); // Default = Variante 2

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVariant = ref.watch(selectedVariantProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Spacer(),

              // Titel
              Text(
                'Matcha',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                      letterSpacing: 8,
                      color: const Color(0xFF98BF8A),
                    ),
              ),

              const SizedBox(height: 80),

              // Variante 1 & 2 Buttons – nur Auswahl, kein Navigieren
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => ref.read(selectedVariantProvider.notifier).state = 1,
                      style: FilledButton.styleFrom(
                        backgroundColor: selectedVariant == 1 ? const Color(0xFF98BF8A) : null,
                      ),
                      child: const Text('Variante 1 – Zen-Modus'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => ref.read(selectedVariantProvider.notifier).state = 2,
                      style: FilledButton.styleFrom(
                        backgroundColor: selectedVariant == 2 ? const Color(0xFF98BF8A) : null,
                      ),
                      child: const Text('Variante 2 – Original'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // Spielmodus-Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {
                        if (selectedVariant == 1) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const GameVariant1Screen()));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const GameVariant2Screen()));
                        }
                      },
                      child: const Text('Solo gegen KI'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {
                        // Hier später Hot-Seat-Modus (gleiche Screen, aber ohne KI)
                        if (selectedVariant == 1) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const GameVariant1Screen()));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const GameVariant2Screen()));
                        }
                      },
                      child: const Text('2 Spieler'),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Untere Icon-Leiste
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())), icon: const Icon(Icons.settings)),
                  const SizedBox(width: 48),
                  IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeaCeremonyInfoScreen())), icon: const Icon(Icons.info_outline)),
                  const SizedBox(width: 48),
                  IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditsScreen())), icon: const Icon(Icons.copyright)),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}