// lib/models/game_state.dart

enum GamePhase {
  warmUp,
  waitingForTapOnBowl,
  waitingForTapOnHand,
  bowlTakenWaitingForKnock,
  bowlTakenWaitingForOwnerDecision,
  gameOver,
}

enum BowlOwner { none, player1, player2OrKI }

class GameState {
  final GamePhase phase;
  final bool isPlayer1Turn;
  final BowlOwner bowlOwner;
  final int fakeCount;
  final String winner;

  const GameState({
    required this.phase,
    required this.isPlayer1Turn,
    required this.bowlOwner,
    required this.fakeCount,
    required this.winner,
  });

  factory GameState.initial() => const GameState(
        phase: GamePhase.warmUp,
        isPlayer1Turn: true,
        bowlOwner: BowlOwner.none,
        fakeCount: 0,
        winner: '',
      );

  GameState copyWith({
    GamePhase? phase,
    bool? isPlayer1Turn,
    BowlOwner? bowlOwner,
    int? fakeCount,
    String? winner,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      isPlayer1Turn: isPlayer1Turn ?? this.isPlayer1Turn,
      bowlOwner: bowlOwner ?? this.bowlOwner,
      fakeCount: fakeCount ?? this.fakeCount,
      winner: winner ?? this.winner,
    );
  }
}