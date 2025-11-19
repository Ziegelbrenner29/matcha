// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:matcha/screens/game_variant1_screen.dart';
import 'package:matcha/screens/game_variant2_screen.dart';
import 'package:matcha/screens/settings_screen.dart';
import 'package:matcha/screens/tea_ceremony_info_screen.dart';
import 'package:matcha/screens/credits_screen.dart';
import 'package:matcha/widgets/chawan_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Spacer(),

              Text(
                'Matcha',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                      letterSpacing: 8,
                    ),
              ),

              const SizedBox(height: 60),

              // Platzhalter-Chawan (im HomeScreen nur Deko → keine Funktion)
              const ChawanWidget(
                onTap: doNothing,
                onLongPressGrab: doNothing,
              ),

              const SizedBox(height: 60),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameVariant1Screen())),
                      child: const Text('Variante 1 – Zen-Modus'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF98BF8A)),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameVariant2Screen())),
                      child: const Text('Variante 2 – Original'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              FilledButton.tonal(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameVariant2Screen())),
                child: const Text('Solo gegen KI'),
              ),

              const Spacer(),

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

  // Dummy-Funktion, damit const möglich ist
  static void doNothing() {}
}