// lib/screens/game_screen.dart
// ────────  KONPIRA GAME SCREEN – 22.11.2025 SPEED-UP + BPM PULSIERT + KORREKT BEIM ERSTEN MAL!  ────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konpira/widgets/chawan_widget.dart';
import 'package:konpira/providers/settings_provider.dart';
import 'package:konpira/providers/bgm_provider.dart';
import 'package:konpira/providers/game_provider.dart';
import 'package:konpira/providers/beat_engine_provider.dart';
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

    // ★★★★★ LIVE BEATENGINE STATE – FÜR EXAKTEN PULS & KORREKTEN BPM BEIM ERSTEN MAL! ★★★★★
    final beatEngineState = ref.watch(beatEngineProvider).state;
    final beatCount = beatEngineState.beatCount;
    final currentBpm = beatEngineState.currentBpm;

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
                ChawanWidget(state: gameState),

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

                // WARMUP-OVERLAY
                if (gameState.phase == GamePhase.warmUp)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Spieler 1:\nTippe im Takt um zu starten',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // BPM-KREIS – PULSIERT EXAKT + KORREKTE BPM BEIM ERSTEN MAL!
                BeatPulseIndicator(
                  bpm: currentBpm,
                  beatCount: beatCount,
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

// ─────── BPM-KREIS – PULSIERT EXAKT IM BEAT + LIVE BPM! ───────
class BeatPulseIndicator extends StatefulWidget {
  final int bpm;
  final int beatCount;
  final double animationIntensity;

  const BeatPulseIndicator({
    required this.bpm,
    required this.beatCount,
    required this.animationIntensity,
    super.key,
  });

  @override
  State<BeatPulseIndicator> createState() => _BeatPulseIndicatorState();
}

class _BeatPulseIndicatorState extends State<BeatPulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _lastBeatCount = -1;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void didUpdateWidget(BeatPulseIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.beatCount != oldWidget.beatCount && widget.beatCount != _lastBeatCount) {
      _lastBeatCount = widget.beatCount;
      _pulseController.forward(from: 0.0).then((_) {
        if (mounted) _pulseController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 140,
      right: 16,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulse = 1.0 + (_pulseController.value * 0.4 * widget.animationIntensity);
          final glowOpacity = _pulseController.value * 0.9 * widget.animationIntensity;

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
                  '${widget.bpm}\nBPM',
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