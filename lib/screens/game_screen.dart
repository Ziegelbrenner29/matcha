// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matcha/providers/game_provider.dart';
import 'package:matcha/models/game_state.dart';
import 'package:matcha/services/beat_engine.dart';
import 'package:matcha/widgets/chawan_widget.dart';
import 'package:matcha/widgets/zen_background.dart';
import 'package:matcha/widgets/player_indicator.dart';  // <-- Jetzt sauber!
import 'package:matcha/core/constants.dart';

class GameScreen extends ConsumerWidget {
  final String variant;

  const GameScreen({required this.variant, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final size = MediaQuery.of(context).size;

    ref.listen(gameProvider, (_, state) {
      if (state.phase == GamePhase.waitingForTapOnBowl && state.winner.isEmpty) {
        ref.read(beatEngineProvider).start(variant);
      }
    });

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) => _handleTap(details.localPosition, size, ref, false),
        onDoubleTapDown: (details) => _handleTap(details.localPosition, size, ref, true),
        onLongPressStart: (details) => _handleLongPress(details.localPosition, size, ref),
        onScaleStart: (_) => _handleScaleStart(ref),
        onScaleUpdate: (details) => _handleScaleUpdate(details, ref),
        onScaleEnd: (_) => _handleScaleEnd(ref),
        child: Stack(
          children: [
            const ZenBackground(),
            ChawanWidget(state: gameState),
            PlayerIndicator(isUpper: true),
            PlayerIndicator(isUpper: false),
            if (gameState.phase == GamePhase.gameOver)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      gameState.winner == 'Du' ? 'Du gewinnst!' : 'Verloren!',
                      style: const TextStyle(fontSize: 64, color: Colors.brown, fontWeight: FontWeight.bold),
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