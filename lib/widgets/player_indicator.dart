// lib/widgets/player_indicator.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matcha/providers/game_provider.dart';

class PlayerIndicator extends ConsumerWidget {
  final bool isUpper;
  const PlayerIndicator({required this.isUpper, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final isTurn = (isUpper && !state.isPlayer1Turn) || (!isUpper && state.isPlayer1Turn);

    return Align(
      alignment: isUpper ? Alignment.topCenter : Alignment.bottomCenter,
      child: AnimatedOpacity(
        opacity: isTurn ? 0.8 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: EdgeInsets.only(top: isUpper ? 40 : 0, bottom: !isUpper ? 40 : 0),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.brown.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            'Dein Zug!',
            style: TextStyle(fontSize: 24, color: Colors.brown[900]),
          ),
        ),
      ),
    );
  }
}