// lib/screens/game_variant2_screen.dart   ← komplett ersetzen!
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matcha/providers/game_provider.dart';
import 'package:matcha/widgets/chawan_widget.dart';
import 'package:matcha/widgets/player_indicator.dart';
import 'package:matcha/widgets/tea_splash_animation.dart';

class GameVariant2Screen extends ConsumerWidget {
  const GameVariant2Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Stack(
          children: [
            // Double-Tap überall außer Schale = Tisch klopfen
            GestureDetector(
              onDoubleTap: gameNotifier.onDoubleTapScreen,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),

            Column(
              children: [
                // Spieler-Anzeige oben
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PlayerIndicator(isActive: game.isPlayer1Turn),
                      PlayerIndicator(isActive: !game.isPlayer1Turn),
                    ],
                  ),
                ),

                const Spacer(),

                // Die Chawan
                ChawanWidget(
                  onTap: gameNotifier.onTapChawan,
                  onLongPressGrab: gameNotifier.onLongPressGrab,
                ),

                const Spacer(),

                // Zurück-Button
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

            // Verlierer-Animation
            if (game.isGameOver)
              TeaSplashAnimation(
                winner: game.winner == 'player1'
                    ? 'Du hast verloren…'
                    : game.winner == 'player2'
                        ? 'Du hast gewonnen!'
                        : 'Die Schale ist umgekippt!',
                onAnimationComplete: gameNotifier.newGame,
              ),
          ],
        ),
      ),
    );
  }
}