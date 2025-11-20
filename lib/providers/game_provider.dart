// lib/providers/game_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:matcha/models/game_state.dart';
import 'package:matcha/core/constants.dart';
import 'package:matcha/services/haptics_service.dart';
import 'package:matcha/services/beat_engine.dart';

final gameProvider = StateNotifierProvider<GameNotifier, MatchaGameState>((ref) {
  return GameNotifier(ref);
});

// Sound-Player für SFX (tok, pon, don, wind)
final AudioPlayer _sfxPlayer = AudioPlayer();

class GameNotifier extends StateNotifier<MatchaGameState> {
  final Ref ref;
  DateTime? _lastBeatTime;
  int _expectedTapType = 0; // 0 = bowl, 1 = hand → wechselt pro Beat

  GameNotifier(this.ref) : super(MatchaGameState(phase: GamePhase.waitingForTapOnBowl)) {
    // Beat-Engine Callback setzen
    ref.read(beatEngineProvider).onBeat = _onBeat;
  }

  void _onBeat() {
    _lastBeatTime = DateTime.now();
    _expectedTapType = _expectedTapType == 0 ? 1 : 0;

    // Nur wenn wir auf normalen Tap warten → Timeout-Check
    if (state.phase == GamePhase.waitingForTapOnBowl ||
        state.phase == GamePhase.waitingForTapOnHand) {
      Future.delayed(Duration(milliseconds: (timingWindowMs * 2).toInt()), () {
        if (_lastBeatTime != null &&
            DateTime.now().difference(_lastBeatTime!) >
                Duration(milliseconds: (timingWindowMs * 2).toInt())) {
          _gameOver('Zu langsam!');
        }
      });
    }
  }

  bool _isInTimingWindow() {
    if (_lastBeatTime == null) return false;
    final diff = DateTime.now().difference(_lastBeatTime!).inMilliseconds.abs();
    return diff <= timingWindowMs;
  }

  // === GESTEN-EVENTS ===

  void onSingleTap(bool isBowlZone, bool isPlayer1Area) async {
    if (state.phase != GamePhase.waitingForTapOnBowl && state.phase != GamePhase.waitingForTapOnHand) return;
    if ((state.isPlayer1Turn && !isPlayer1Area) || (!state.isPlayer1Turn && isPlayer1Area)) return;

    final expectedBowl = _expectedTapType == 0;
    if (isBowlZone != expectedBowl) {
      await _playSfx(soundDon); // Falsch → lautes DON als Strafe
      _gameOver('Falsche Aktion!');
      return;
    }
    if (!_isInTimingWindow()) {
      await _playSfx(soundDon);
      _gameOver('Falsches Timing!');
      return;
    }

    // RICHTIG!
    await _playSfx(isBowlZone ? soundTok : soundPon);
    HapticsService.light();
    state = state.copyWith(isPlayer1Turn: !state.isPlayer1Turn);
  }

  void onLiftBowl(bool isPlayer1) async {
    if (state.bowlOwner != BowlOwner.none) return;
    if ((isPlayer1 && !state.isPlayer1Turn) || (!isPlayer1 && state.isPlayer1Turn)) return;

    await _playSfx(soundWind);
    HapticsService.medium();

    state = state.copyWith(
      phase: GamePhase.bowlTakenWaitingForKnock,
      bowlOwner: isPlayer1 ? BowlOwner.player1 : BowlOwner.player2OrKI,
    );
  }

  void onDoubleTapMiddle() async {
    if (state.phase != GamePhase.bowlTakenWaitingForKnock) {
      await _playSfx(soundDon);
      _gameOver('Geklopft obwohl Schale da!');
      return;
    }
    if (!_isInTimingWindow()) {
      await _playSfx(soundDon);
      _gameOver('Falsches Timing beim Klopfen!');
      return;
    }

    await _playSfx(soundDon);
    HapticsService.heavy();

    state = state.copyWith(phase: GamePhase.bowlTakenWaitingForOwnerDecision);
  }

  // Wird aufgerufen, wenn der Besitzer die Finger loslässt → ehrlich abstellen
  void onOwnerDecisionRelease() {
    _placeBowlHonestly();
  }

  // Wird aufgerufen bei Pinch-Out oder halten → Fake-Out!
  void onOwnerDecisionFake() async {
    if (state.fakeCount >= maxFakesInARow) {
      _placeBowlHonestly(); // Zwang nach max Fakes
      return;
    }

    HapticsService.light(); // Teuflisches Kichern
    state = state.copyWith(
      phase: GamePhase.bowlTakenWaitingForKnock,
      fakeCount: state.fakeCount + 1,
    );

    // Kurze Berührung + sofort wieder hoch
    await Future.delayed(fakeTouchDuration);
    // Animation wird vom ChawanWidget übernommen
  }

  void _placeBowlHonestly() {
    final nextPhase = _expectedTapType == 0 ? GamePhase.waitingForTapOnBowl : GamePhase.waitingForTapOnHand;
    state = state.copyWith(
      phase: nextPhase,
      bowlOwner: BowlOwner.none,
      fakeCount: 0,
      isPlayer1Turn: !state.isPlayer1Turn,
    );
  }

  void _gameOver(String reason) async {
    await _playSfx(soundDon); // Trauriges DON
    HapticsService.heavy();
    final winner = state.isPlayer1Turn ? 'Gegner / KI' : 'Du';
    state = state.copyWith(
      phase: GamePhase.gameOver,
      winner: winner,
    );
  }

  Future<void> _playSfx(String asset) async {
    try {
      await _sfxPlayer.setAsset(asset);
      await _sfxPlayer.play();
    } catch (_) {}
  }

  void reset() {
    state = MatchaGameState(phase: GamePhase.waitingForTapOnBowl);
    _expectedTapType = 0;
    _lastBeatTime = null;
  }

  @override
  void dispose() {
    _sfxPlayer.dispose();
    super.dispose();
  }
}