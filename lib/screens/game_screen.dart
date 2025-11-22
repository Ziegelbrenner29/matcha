// lib/screens/game_screen.dart
// ────────  KONPIRA GAME SCREEN – 22.11.2025 MIT PULSIERENDEM BPM-KREIS!  ────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konpira/widgets/chawan_widget.dart';
import 'package:konpira/providers/settings_provider.dart';
import 'package:konpira/providers/bgm_provider.dart';
import 'package:konpira/providers/game_provider.dart';
import 'package:konpira/models/game_state.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with TickerProviderStateMixin {
  double lastContactSize = 0.0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bgmProvider).setGameScreen(true);
    });

    ref.read(gameProvider.notifier).startKonpiraSong();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    ref.read(gameProvider.notifier).stopKonpiraSong();
    ref.read(bgmProvider).setGameScreen(false);
    super.dispose();
  }

  String get tableAsset => switch (ref.watch(settingsProvider).theme) {
        AppTheme.washiClassic  => 'assets/images/themes/table_washi.jpg',
        AppTheme.matchaGarden  => 'assets/images/themes/table_garden.jpg',
        AppTheme.goldenTemple  => 'assets/images/themes/table_temple.jpg',
      };

  String getIndicatorAsset(AppTheme theme) => switch (theme) {
        AppTheme.washiClassic => 'assets/images/indicators/lampion.png',
        AppTheme.matchaGarden => 'assets/images/indicators/sakura.png',
        AppTheme.goldenTemple => 'assets/images/indicators/temple_bell.png',
      };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final settings = ref.watch(settingsProvider);
    final gameState = ref.watch(gameProvider);
    final isPlayerOneTurn = gameState.isPlayer1Turn;
    final faceEachOther = settings.playersFaceEachOther;

    // ★★★★★ LIVE BPM BERECHNUNG ★★★★★
    final currentBpm = (60000 / settings.gameDifficulty.baseBeatIntervalMs).round();

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
              image: AssetImage(settings.theme.paperAsset),
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
                // Tisch
                Center(
                  child: Image.asset(
                    tableAsset,
                    width: size.width,
                    fit: BoxFit.fitWidth,
                  ),
                ),

                // Chawan
                Center(
                  child: ChawanWidget(state: gameState),
                ),

                // PVP-INDIKATOREN
                _PlayerTurnIndicator(
                  isActive: isPlayerOneTurn,
                  alignment: faceEachOther ? Alignment.bottomLeft : Alignment.topLeft,
                  rotation: 0,
                  asset: getIndicatorAsset(settings.theme),
                  pulseController: _pulseController,
                  animationIntensity: settings.animationIntensity,
                ),

                _PlayerTurnIndicator(
                  isActive: !isPlayerOneTurn,
                  alignment: faceEachOther ? Alignment.topRight : Alignment.topRight,
                  rotation: faceEachOther ? 180 : 0,
                  asset: getIndicatorAsset(settings.theme),
                  pulseController: _pulseController,
                  animationIntensity: settings.animationIntensity,
                ),

                // ★★★★★ NEU: PULSIERENDER BPM-KREIS – HERZSCHLAG DES SCHREINS! ★★★★★
                BeatPulseIndicator(
                  pulseController: _pulseController,
                  bpm: currentBpm,
                  animationIntensity: settings.animationIntensity,
                ),

                // Game Over
                if (gameState.phase == GamePhase.gameOver)
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(gameProvider.notifier).resetGame();
                        ref.read(gameProvider.notifier).startKonpiraSong();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                      ),
                      child: const Text('Nochmal!', style: TextStyle(fontSize: 32, color: Colors.white)),
                    ),
                  ),

                // Debug
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
                      'Kontakt: ${lastContactSize.round()} px²',
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

// ─────── PULSIERENDER INDIKATOR (unverändert) ───────
class _PlayerTurnIndicator extends StatelessWidget {
  final bool isActive;
  final Alignment alignment;
  final double rotation;
  final String asset;
  final AnimationController pulseController;
  final double animationIntensity;

  const _PlayerTurnIndicator({
    required this.isActive,
    required this.alignment,
    required this.rotation,
    required this.asset,
    required this.pulseController,
    required this.animationIntensity,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final indicatorSize = size.width * 0.22;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.08),
        child: AnimatedBuilder(
          animation: pulseController,
          builder: (context, child) {
            final pulseValue = isActive ? (0.95 + pulseController.value * 0.1) * animationIntensity : 0.8;
            final opacity = isActive ? 1.0 : 0.4;

            return Opacity(
              opacity: opacity,
              child: Transform.rotate(
                angle: rotation * 3.14159 / 180,
                child: Transform.scale(
                  scale: pulseValue,
                  child: Container(
                    width: indicatorSize,
                    height: indicatorSize,
                    decoration: BoxDecoration(
                      boxShadow: isActive
                          ? [BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 20, spreadRadius: 5)]
                          : null,
                    ),
                    child: Image.asset(
                      asset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(Icons.circle, size: indicatorSize, color: isActive ? Colors.amber : Colors.grey),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────── NEU: PULSIERENDER BPM-KREIS – ATME MIT DEM LIED! ───────
class BeatPulseIndicator extends StatelessWidget {
  final AnimationController pulseController;
  final int bpm;
  final double animationIntensity;

  const BeatPulseIndicator({
    required this.pulseController,
    required this.bpm,
    required this.animationIntensity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 140,
      right: 16,
      child: AnimatedBuilder(
        animation: pulseController,
        builder: (context, child) {
          final pulse = 1.0 + (pulseController.value * 0.4) * animationIntensity; // Starkes Pulsieren
          final glowOpacity = pulseController.value * 0.8 * animationIntensity;

          return Transform.scale(
            scale: pulse,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4A3728).withOpacity(0.95),
                border: Border.all(color: const Color(0xFF8B9F7A), width: 5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B9F7A).withOpacity(glowOpacity),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$bpm\nBPM',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}