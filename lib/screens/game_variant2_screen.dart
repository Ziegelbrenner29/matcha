// lib/screens/game_variant2_screen.dart
import 'package:flutter/material.dart';
import 'package:matcha/widgets/chawan_widget.dart';
import 'package:matcha/widgets/player_indicator.dart';

class GameVariant2Screen extends StatelessWidget {
  const GameVariant2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Oben: Spieler-Anzeige (wird später pulsieren)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PlayerIndicator(isActive: true),  // Spieler 1 (du)
                  PlayerIndicator(isActive: false), // Gegner / KI
                ],
              ),
            ),

            const Spacer(),

            // Die Chawan in der Mitte – hier passiert später die ganze Magie
            ChawanWidget(
              onTap: () {
                debugPrint('Tap – Schale leicht gedreht');
                // Später: Sound + Haptik + Zufalls-Umkippen
              },
              onLongPressGrab: () {
                debugPrint('Long-Press ≥ 400 ms – weggegriffen!');
                // Später: Animation + 850 ms Timer für Double-Tap starten
              },
            ),

            const Spacer(),

            // Zurück-Button (klein unten links)
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}