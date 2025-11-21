// lib/providers/game_provider.dart
import 'package:flutter/foundation.dart'; // für debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:konpira/models/game_state.dart';
import 'package:konpira/core/constants.dart';
import 'package:konpira/services/haptics_service.dart';
import 'package:konpira/providers/beat_engine_provider.dart';
import 'package:konpira/providers/settings_provider.dart'; // für bgmVolume!

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref);
});

// SFX Player (tok/pon/don/wind)
final AudioPlayer _sfxPlayer = AudioPlayer();

// BGM Player – looped Konpira fune fune
final AudioPlayer _bgmPlayer = AudioPlayer();

class GameNotifier extends StateNotifier<GameState> {
  final Ref ref;
  DateTime? _lastBeatTime;
  int _expectedTapType = 0;
  bool _isVsKI = false;

  GameNotifier(this.ref) : super(GameState.initial()) {
    ref.read(beatEngineProvider).onBeat = _onBeat;
  }

  void setGameMode(bool isVsKI) => _isVsKI = isVsKI;

  void _onBeat() {
    _lastBeatTime = DateTime.now();
    _expectedTapType = _expectedTapType == 0 ? 1 : 0;

    if (state.phase == GamePhase.waitingForTapOnBowl || state.phase == GamePhase.waitingForTapOnHand) {
      Future.delayed(Duration(milliseconds: (timingWindowMs * 2).round()), () {
        if (_lastBeatTime != null &&
            DateTime.now().difference(_lastBeatTime!) > Duration(milliseconds: (timingWindowMs * 2).round())) {
          _gameOver(state.isPlayer1Turn ? 'player2' : 'player1');
        }
      });
    }
  }

  bool _isInTimingWindow() {
    if (_lastBeatTime == null) return false;
    final diff = DateTime.now().difference(_lastBeatTime!).inMilliseconds.abs();
    return diff <= timingWindowMs;
  }

  // === BGM START / STOP ===
  Future<void> startMusic(String variant) async {
  if (_bgmPlayer.playing) return;  // verhindert doppeltes Abspielen

  final String asset;
  if (variant == 'konpira') {
    asset = 'assets/audio/konpira_fune_fune.mp3';
  } else if (variant == 'matchapon') {
    asset = 'assets/audio/matcha_pon.mp3';  // später hinzufügen
  } else {
    debugPrint('🎶 Unbekannte Variante: $variant – keine Musik!');
    return;
  }

  try {
    await _bgmPlayer.setAsset(asset);
    await _bgmPlayer.setLoopMode(LoopMode.one);
    final volume = ref.read(settingsProvider).bgmVolume;
    await _bgmPlayer.setVolume(volume.clamp(0.0, 1.0));
    await _bgmPlayer.play();
    debugPrint('🎶 $variant gestartet – Asset: $asset, Volume: $volume');
  } catch (e) {
    debugPrint('BGM Fehler ($variant): $e');
  }
}

  Future<void> stopMusic() async {
    await _bgmPlayer.stop();
  }

  // === GESTEN ===
  void onSingleTap(bool isBowlZone, bool isPlayer1Area) async {
    if (state.phase != GamePhase.waitingForTapOnBowl && state.phase != GamePhase.waitingForTapOnHand) return;
    if ((state.isPlayer1Turn && !isPlayer1Area) || (!state.isPlayer1Turn && isPlayer1Area)) return;

    final expectedBowl = _expectedTapType == 0;
    if (isBowlZone != expectedBowl || !_isInTimingWindow()) {
      await _playSfx(soundDon);
      HapticsService.heavy();
      _gameOver(state.isPlayer1Turn ? 'player2' : 'player1');
      return;
    }

    await _playSfx(isBowlZone ? soundTok : soundPon);
    HapticsService.light();
    state = state.copyWith(isPlayer1Turn: !state.isPlayer1Turn);
  }

  void onDoubleTapMiddle() async {
    if (state.phase != GamePhase.bowlTakenWaitingForKnock || !_isInTimingWindow()) {
      await _playSfx(soundDon);
      HapticsService.heavy();
      _gameOver(state.isPlayer1Turn ? 'player2' : 'player1');
      return;
    }

    await _playSfx(soundDon);
    HapticsService.heavy();
    state = state.copyWith(phase: GamePhase.bowlTakenWaitingForOwnerDecision);
  }

  void onLiftBowl(bool isPlayer1Turn) async {
    if (state.bowlOwner != BowlOwner.none || state.isPlayer1Turn != isPlayer1Turn) return;

    await _playSfx(soundWind);
    HapticsService.medium();
    state = state.copyWith(
      phase: GamePhase.bowlTakenWaitingForKnock,
      bowlOwner: isPlayer1Turn ? BowlOwner.player1 : BowlOwner.player2OrKI,
    );
  }

  void onOwnerDecisionFake() async {
    if (state.fakeCount >= maxFakesInARow) {
      _placeBowlHonestly();
      return;
    }

    HapticsService.light();
    state = state.copyWith(
      phase: GamePhase.bowlTakenWaitingForKnock,
      fakeCount: state.fakeCount + 1,
    );
    await Future.delayed(fakeTouchDuration);
  }

  void onOwnerDecisionRelease() {
    _placeBowlHonestly();
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

  void _gameOver(String winner) async {
    await _playSfx(soundDon);
    HapticsService.heavy();
    await stopMusic();
    state = state.copyWith(phase: GamePhase.gameOver, winner: winner);
  }

  Future<void> _playSfx(String asset) async {
    try {
      await _sfxPlayer.setAsset(asset);
      await _sfxPlayer.play();
    } catch (e) {
      debugPrint('SFX Error: $e');
    }
  }

  void reset() {
    state = GameState.initial();
    _expectedTapType = 0;
    _lastBeatTime = null;
    stopMusic();
  }

  @override
  void dispose() {
    _sfxPlayer.dispose();
    _bgmPlayer.dispose();
    super.dispose();
  }
}