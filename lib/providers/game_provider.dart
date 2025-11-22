// lib/providers/game_provider.dart
// ────────  KONPIRA GAME PROVIDER – 22.11.2025 LIED + BEATENGINE PERFEKT SYNC!  ────────

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

// KONPIRA FUNE FUNE LIED PLAYER (stabil wie ein Tempel!)
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

  // ★★★★★ KONPIRA FUNE FUNE LIED + BEATENGINE START – LIED SINGT WIEDER SOFORT! ★★★★★
  Future<void> startKonpiraSong() async {
    try {
      final settings = ref.read(settingsProvider);

      // Lied starten – SOFORT + LAUT!
      await _konpiraSongPlayer.setAsset(soundKonpira);
      await _konpiraSongPlayer.setLoopMode(LoopMode.one);
      await _konpiraSongPlayer.setVolume(settings.masterVolume * settings.bgmVolume);
      await _konpiraSongPlayer.play();

      // BeatEngine starten – OHNE await (ist sync!)
      ref.read(beatEngineProvider).start(ref);

      debugPrint('🎶 Konpira fune fune + BeatEngine gestartet – ${settings.gameDifficulty} Mode! LIED LÄUFT!');
    } catch (e) {
      debugPrint('Start Fehler: $e');
    }
  }

  Future<void> stopKonpiraSong() async {
    await _konpiraSongPlayer.stop();
    ref.read(beatEngineProvider).dispose();
  }

  // Für Settings Test-Button (funktioniert wieder 100%!)
  Future<void> startMusic(String variant) async => await startKonpiraSong();
  Future<void> stopMusic() async => await stopKonpiraSong();

  // === GESTEN ===
  Future<void> _playSfx(String asset) async {
    try {
      await _sfxPlayer.setAsset(asset);
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

  void _gameOver(String winner) async {
    await _playSfx(soundDon);
    HapticsService.heavy();
    await stopKonpiraSong();
    state = state.copyWith(phase: GamePhase.gameOver, winner: winner);
  }

  // RESET FÜR "NOCHMAL!" BUTTON
  void resetGame() {
    state = GameState.initial();
    _expectedTapType = 0;
    _lastBeatTime = null;
    stopKonpiraSong();
    startKonpiraSong();  // ← Lied + BeatEngine neu starten!
  }

  @override
  void dispose() {
    _sfxPlayer.dispose();
    _konpiraSongPlayer.dispose();
    ref.read(beatEngineProvider).dispose();
    super.dispose();
  }
}