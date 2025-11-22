// lib/providers/game_provider.dart
// ────────  KONPIRA GAME PROVIDER – 22.11.2025 JUST_AUDIO.SETSPEED + SPEED-UP CHAOS-ZEN!  ────────

import 'dart:async';
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

  Timer? _speedUpTimer;
  double _currentSpeed = 1.0; // Start-Speed

  GameNotifier(this.ref) : super(GameState.initial()) {
    ref.read(beatEngineProvider).onBeat = _onBeat;
  }

  void setGameMode(bool isVsKI) => _isVsKI = isVsKI;

  void _onBeat() {
    _lastBeatTime = DateTime.now();
    _expectedTapType = _expectedTapType == 0 ? 1 : 0;

    if (state.phase == GamePhase.warmUp) {
      return;
    }

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

  // ★★★★★ KONPIRA FUNE FUNE LIED + BEATENGINE START! ★★★★★
Future<void> startKonpiraSong() async {
  try {
    final settings = ref.read(settingsProvider);
    _currentSpeed = settings.gameDifficulty.speedMultiplier;

    await _konpiraSongPlayer.setAsset(soundKonpira);
    await _konpiraSongPlayer.setLoopMode(LoopMode.one);
    await _konpiraSongPlayer.setVolume(settings.masterVolume * settings.bgmVolume);
    await _konpiraSongPlayer.setSpeed(_currentSpeed);
    _konpiraSongPlayer.play();  // ← OHNE await!

    // ★★★★★ BeatEngine STARTEN (nicht nur BPM updaten!) ★★★★★
    final currentBpm = (92 * _currentSpeed).round();
    ref.read(beatEngineProvider).start(currentBpm);  // ← .start() statt .updateBpm()!

    // Speed-Up-Timer starten (wenn aktiviert)
    _speedUpTimer?.cancel();
    if (settings.speedUpPerRound) {
      _speedUpTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        _currentSpeed += 0.1;
        _konpiraSongPlayer.setSpeed(_currentSpeed);
        final newBpm = (92 * _currentSpeed).round();
        ref.read(beatEngineProvider).updateBpm(newBpm);  // ← Hier .updateBpm() OK!
        debugPrint('⚡ Chaos-Zen! Speed-Up auf $_currentSpeed → $newBpm BPM');
      });
    }

    debugPrint('🎶 Konpira gestartet: Speed $_currentSpeed → $currentBpm BPM!');
  } catch (e, stack) {
    debugPrint('❌ Start Fehler: $e\n$stack');
  }
}

  Future<void> stopKonpiraSong() async {
    _speedUpTimer?.cancel();
    await _konpiraSongPlayer.stop();
    ref.read(beatEngineProvider).stop();
  }

  // TESTBUTTON – NUR LIED, KEIN SPEED-UP!
  Future<void> startMusic(String variant) async {
    try {
      final settings = ref.read(settingsProvider);
      await _konpiraSongPlayer.setAsset(soundKonpira);
      await _konpiraSongPlayer.setLoopMode(LoopMode.one);
      await _konpiraSongPlayer.setVolume(settings.masterVolume * settings.bgmVolume);
      await _konpiraSongPlayer.play();
      debugPrint('🎶 Test-Musik gestartet (Speed 1.0x)');
    } catch (e) {
      debugPrint('Test-Musik Fehler: $e');
    }
  }

  Future<void> stopMusic() async {
    await _konpiraSongPlayer.stop();
  }

  // GESTEN + GAMEOVER + RESET wie vorher

  // In GameNotifier – _playSfx wieder hinzufügen!
Future<void> _playSfx(String asset) async {
  try {
    await _sfxPlayer.setAsset(asset);
    await _sfxPlayer.play();
  } catch (e) {
    debugPrint('SFX Error: $e');
  }
}

  void onSingleTap(bool isBowlZone, bool isPlayer1Area) async {
    if (state.phase == GamePhase.warmUp) {
      if (isPlayer1Area) {
        state = state.copyWith(phase: GamePhase.waitingForTapOnBowl, isPlayer1Turn: false);
        await _playSfx(soundTok);
        HapticsService.light();
      }
      return;
    }

    // ... Rest wie vorher
  }

  void _gameOver(String winner) async {
    await _playSfx(soundDon);
    HapticsService.heavy();
    await stopKonpiraSong();
    state = state.copyWith(phase: GamePhase.gameOver, winner: winner);
  }

  void resetGame() {
    _speedUpTimer?.cancel();
    _currentSpeed = ref.read(settingsProvider).gameDifficulty.speedMultiplier;
    state = GameState.initial();
    _expectedTapType = 0;
    _lastBeatTime = null;
    stopKonpiraSong();
    startKonpiraSong();
  }

  @override
  void dispose() {
    _speedUpTimer?.cancel();
    _sfxPlayer.dispose();
    _konpiraSongPlayer.dispose();
    ref.read(beatEngineProvider).dispose();
    super.dispose();
  }
}