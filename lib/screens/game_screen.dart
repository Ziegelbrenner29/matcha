// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konpira/widgets/chawan_widget.dart';
import 'package:konpira/providers/settings_provider.dart';
import 'package:konpira/providers/bgm_provider.dart';
import 'package:konpira/providers/game_provider.dart';   // ← für start/stop Konpira-Lied
import 'package:konpira/models/game_state.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  String debugText = 'Bereit – teste Gesten!';
  double lastContactSize = 0.0;

  String get tableAsset => switch (ref.watch(settingsProvider).theme) {
        AppTheme.washiClassic  => 'assets/images/themes/table_washi.jpg',
        AppTheme.matchaGarden  => 'assets/images/themes/table_garden.jpg',
        AppTheme.goldenTemple  => 'assets/images/themes/table_temple.jpg',
      };

  @override
  void initState() {
    super.initState();

    // BGM (Hintergrundmusik) aus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bgmProvider).setGameScreen(true);
    });

    // KONPIRA FUNE FUNE LIED STARTEN + LOOP
    ref.read(gameProvider.notifier).startKonpiraSong(); // looped automatisch
  }

  @override
  void dispose() {
    // Beim Verlassen: Lied + BGM wieder normal
    ref.read(gameProvider.notifier).stopKonpiraSong();
    ref.read(bgmProvider).setGameScreen(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gameState = ref.watch(gameProvider);

    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          ref.read(gameProvider.notifier).stopKonpiraSong();
          await ref.read(bgmProvider).setGameScreen(false);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ref.watch(settingsProvider).theme.paperAsset),
              fit: BoxFit.cover,
              opacity: 0.6,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5F0E1), Color(0xFFE8DAB2)],
            ),
          ),
          child: Listener(
            onPointerDown: (event) {
              lastContactSize = event.size;
              setState(() {});
            },
            child: Stack(
              children: [
                // Tisch – 100% Breite, perfekt mittig
                Center(
                  child: Image.asset(
                    tableAsset,
                    width: size.width,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.center,
                  ),
                ),

                // Chawan
                const Center(
                  child: ChawanWidget(state: GameState(
                    phase: GamePhase.waitingForTapOnBowl,
                    isPlayer1Turn: true,
                    bowlOwner: BowlOwner.none,
                    fakeCount: 0,
                    winner: '',
                  )),
                ),

                // Spielende: "Nochmal!" Button → Lied stoppen + neu starten bei Klick
                if (gameState.phase == GamePhase.gameOver)
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(gameProvider.notifier).resetGame();
                        ref.read(gameProvider.notifier).startKonpiraSong(); // von vorne neu!
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                      ),
                      child: const Text('Nochmal!', style: TextStyle(fontSize: 32, color: Colors.white)),
                    ),
                  ),

                // Debug-Overlay
                Positioned(
                  bottom: 80,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Kontaktfläche: ${lastContactSize.round()} px²',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}