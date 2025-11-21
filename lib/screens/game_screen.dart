// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konpira/providers/game_provider.dart';
import 'package:konpira/providers/beat_engine_provider.dart';
import 'package:konpira/models/game_state.dart';
import 'package:konpira/widgets/chawan_widget.dart';
import 'package:konpira/widgets/player_indicator.dart';
import 'package:konpira/core/constants.dart';
import 'package:konpira/providers/settings_provider.dart';  // <<< NEU: für theme.paperAsset!

class GameScreen extends ConsumerWidget {
  final String variant;
  final bool isVsKI;

  const GameScreen({required this.variant, required this.isVsKI, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final size = MediaQuery.of(context).size;
    final theme = ref.watch(settingsProvider).theme;  // <<< LIVE THEME!

    // Musik + Beat starten automatisch
    ref.listen<GameState>(gameProvider, (previous, next) {
      if (next.phase == GamePhase.waitingForTapOnBowl && next.winner.isEmpty) {
        debugPrint('🎶 GameScreen: waitingForTapOnBowl erkannt – Variant: $variant');
        ref.read(beatEngineProvider).start(variant);
        ref.read(gameProvider.notifier).startMusic(variant);
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(theme.paperAsset),  // <<< Paper-Textur aus Theme!
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F0E1), Color(0xFFE8DAB2)],
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _handleTap(d.localPosition, size, ref, false),
          onDoubleTapDown: (d) => _handleTap(d.localPosition, size, ref, true),
          onLongPressStart: (d) => _handleLongPress(d.localPosition, size, ref),
          onScaleStart: (_) => _handleScaleStart(ref),
          onScaleUpdate: (d) => _handleScaleUpdate(d, ref),
          onScaleEnd: (_) => _handleScaleEnd(ref),
          child: Stack(
            children: [
              ChawanWidget(state: gameState),  // wechselt schon live!
              const PlayerIndicator(isUpper: true),
              const PlayerIndicator(isUpper: false),
              if (gameState.phase == GamePhase.gameOver)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        gameState.winner == 'player1' ? 'Du gewinnst!' : 'Verloren!',
                        style: const TextStyle(fontSize: 64, color: Color(0xFF4A3728), fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(gameProvider.notifier).reset();
                          ref.read(beatEngineProvider).start(variant);
                        },
                        child: const Text('Nochmal!', style: TextStyle(fontSize: 32)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  HitZone _getZone(Offset pos, Size size) {
    final y = pos.dy / size.height;
    if (y < upperHandZoneRatio) return HitZone.upperHand;
    if (y > 1 - lowerHandZoneRatio) return HitZone.lowerHand;
    return HitZone.bowl;
  }

  void _handleTap(Offset pos, Size size, WidgetRef ref, bool isDouble) {
    final zone = _getZone(pos, size);
    final isPlayer1Area = zone == HitZone.lowerHand;

    if (isDouble && zone == HitZone.bowl) {
      ref.read(gameProvider.notifier).onDoubleTapMiddle();
    } else if (!isDouble) {
      final isBowlZone = zone == HitZone.bowl;
      ref.read(gameProvider.notifier).onSingleTap(isBowlZone, isPlayer1Area);
    }
  }

  void _handleLongPress(Offset pos, Size size, WidgetRef ref) {
    final zone = _getZone(pos, size);
    if (zone != HitZone.bowl) return;
    final state = ref.read(gameProvider);
    if (state.phase == GamePhase.waitingForTapOnBowl || state.phase == GamePhase.waitingForTapOnHand) {
      ref.read(gameProvider.notifier).onLiftBowl(state.isPlayer1Turn);
    }
  }

  void _handleScaleStart(WidgetRef ref) {
    final state = ref.read(gameProvider);
    if (state.phase == GamePhase.waitingForTapOnBowl || state.phase == GamePhase.waitingForTapOnHand) {
      ref.read(gameProvider.notifier).onLiftBowl(state.isPlayer1Turn);
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, WidgetRef ref) {
    final state = ref.read(gameProvider);
    if (state.phase == GamePhase.bowlTakenWaitingForOwnerDecision && details.scale > 1.1) {
      ref.read(gameProvider.notifier).onOwnerDecisionFake();
    }
  }

  void _handleScaleEnd(WidgetRef ref) {
    final state = ref.read(gameProvider);
    if (state.phase == GamePhase.bowlTakenWaitingForOwnerDecision) {
      ref.read(gameProvider.notifier).onOwnerDecisionRelease();
    }
  }
}

enum HitZone { upperHand, bowl, lowerHand }