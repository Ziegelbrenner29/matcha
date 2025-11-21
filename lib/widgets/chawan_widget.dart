// lib/widgets/chawan_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konpira/models/game_state.dart';
import 'package:konpira/providers/settings_provider.dart';  // für theme.chawanAsset
import 'package:konpira/core/constants.dart';

class ChawanWidget extends ConsumerWidget {
  final GameState state;

  const ChawanWidget({required this.state, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final bowlSize = size.width * 0.25;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    late Offset targetPosition;
    late double scale;
    late double rotation;

    switch (state.phase) {
      case GamePhase.gameOver:
        scale = 0.0;
        targetPosition = Offset(centerX, centerY);
        rotation = 0;
        break;
      case GamePhase.bowlTakenWaitingForKnock:
      case GamePhase.bowlTakenWaitingForOwnerDecision:
        final ownerY = state.bowlOwner == BowlOwner.player1 
            ? size.height * 0.8 
            : size.height * 0.2;
        targetPosition = Offset(centerX, ownerY);
        scale = 1.1;
        rotation = state.bowlOwner == BowlOwner.player1 ? 15 : -15;
        break;
      default:
        targetPosition = Offset(centerX, centerY);
        scale = 1.0;
        rotation = 0;
        break;
    }

    // <<< LIVE WECHSEL: Chawan aus themes-Ordner je nach Theme!
    final chawanAsset = ref.watch(settingsProvider.select((s) => s.theme.chawanAsset));

    return AnimatedPositioned(
      duration: state.phase == GamePhase.bowlTakenWaitingForOwnerDecision && state.fakeCount > 0
          ? fakeTouchDuration
          : const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      left: targetPosition.dx - bowlSize / 2,
      top: targetPosition.dy - bowlSize / 2,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 300),
        child: AnimatedRotation(
          turns: rotation / 360,
          duration: const Duration(milliseconds: 400),
          child: Image.asset(
            chawanAsset,
            width: bowlSize,
            height: bowlSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}