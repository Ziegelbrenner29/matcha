// lib/providers/game_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:konpira/models/game_state.dart';
import 'package:konpira/core/constants.dart';
import 'package:konpira/services/haptics_service.dart';
import 'package:konpira/providers/beat_engine_provider.dart';
import 'package:konpira/providers/settings_provider.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref);
});

// SFX Player
final AudioPlayer _sfxPlayer = AudioPlayer();

// KONPIRA FUNE FUNE LIED PLAYER
final AudioPlayer _konpiraSongPlayer = AudioPlayer();

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
      Future.delayed(Duration(milliseconds: ref.read(settingsProvider).timingWindowMs * 2), () {
        if (_lastBeatTime != null &&
            DateTime.now().difference(_lastBeatTime!) > Duration(milliseconds: ref.read(settingsProvider).timingWindowMs * 2)) {
          _gameOver(state.isPlayer1Turn ? 'player2' : 'player1');
        }
      });
    }
  }

  bool _isInTimingWindow() {
    if (_lastBeatTime == null) return false;
    final diff = DateTime.now().difference(_lastBeatTime!).inMilliseconds.abs();
    return diff <= ref.read(settingsProvider).timingWindowMs;
  }

  // ★★★★★ KONPIRA FUNE FUNE LIED – START / STOP / RESET ★★★★★
  Future<void> startKonpiraSong() async {
    try {
      await _konpiraSongPlayer.setAsset('assets/audio/konpira_fune_fune.mp3');
      await _konpiraSongPlayer.setLoopMode(LoopMode.one);
      final masterVol = ref.read(settingsProvider).masterVolume;
      await _konpiraSongPlayer.setVolume(masterVol);
      await _konpiraSongPlayer.play();
      debugPrint('🎶 Konpira fune fune gestartet + looped');
    } catch (e) {
      debugPrint('Konpira Song Fehler: $e');
    }
  }

  Future<void> stopKonpiraSong() async {
    await _konpiraSongPlayer.stop();
  }

  // Für Settings Test-Button (kompatibel mit altem Code)
  Future<void> startMusic(String variant) async => await startKonpiraSong();
  Future<void> stopMusic() async => await stopKonpiraSong();

  // === GESTEN ===
  Future<void> _playSfx(String asset) async {
    try {
      await _sfxPlayer.setAsset(asset);
      await _sfxPlayer.play();
    await _sfxPlayer.play();
    } catch (e) {
      debugPrint('SFX Error: $e');
    }
  }

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

  // ... (dein Rest-Code bleibt unverändert: onDoubleTapMiddle, onLiftBowl, etc.)

  void _gameOver(String winner) async {
    await _playSfx(soundDon);
    HapticsService.heavy();
    await stopKonpiraSong();  // ← Lied stoppt bei Game Over
    state = state.copyWith(phase: GamePhase.gameOver, winner: winner);
  }

  // RESET FÜR "NOCHMAL!" BUTTON
  void resetGame() {
    state = GameState.initial();
    _expectedTapType = 0;
    _lastBeatTime = null;
    stopKonpiraSong();
    startKonpiraSong();  // ← neu von vorne!
  }

  @override
  void dispose() {
    _sfxPlayer.dispose();
    _konpiraSongPlayer.dispose();
    super.dispose();
  }
}