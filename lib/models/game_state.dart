// lib/models/game_state.dart
enum GamePhase {
  waitingForTapOnBowl,        // Erwartet Tippen auf Schale
  waitingForTapOnHand,        // Erwartet Tippen auf eigene Hand
  bowlTakenWaitingForKnock,   // Schale weg → Gegner muss klopfen
  bowlTakenWaitingForOwnerDecision, // Gegner hat richtig geklopft → Fake oder ehrlich?
  gameOver,
}

enum BowlOwner { none, player1, player2OrKI }

class MatchaGameState {
  final GamePhase phase;
  final BowlOwner bowlOwner;
  final bool isPlayer1Turn;     // wer ist gerade dran
  final int fakeCount;          // wie viele Fakes in Folge
  final String winner;          // 'player1', 'player2', 'ki' oder ''

  MatchaGameState({
    required this.phase,
    this.bowlOwner = BowlOwner.none,
    this.isPlayer1Turn = true,
    this.fakeCount = 0,
    this.winner = '',
  });

  MatchaGameState copyWith({
    GamePhase? phase,
    BowlOwner? bowlOwner,
    bool? isPlayer1Turn,
    int? fakeCount,
    String? winner,
  }) {
    return MatchaGameState(
      phase: phase ?? this.phase,
      bowlOwner: bowlOwner ?? this.bowlOwner,
      isPlayer1Turn: isPlayer1Turn ?? this.isPlayer1Turn,
      fakeCount: fakeCount ?? this.fakeCount,
      winner: winner ?? this.winner,
    );
  }
}