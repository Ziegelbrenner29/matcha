// lib/providers/game_provider.dart  ← komplett ersetzen!
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:just_audio/just_audio.dart';

final gameProvider = ChangeNotifierProvider<GameProvider>((ref) => GameProvider._());

class GameProvider extends ChangeNotifier {
  GameProvider._() {
    _vibrate = ([HapticsType? type]) => Haptics.vibrate(type ?? HapticsType.light);
    Haptics.canVibrate().then((value) => _canVibrate = value);
  }

  // State
  bool isPlayer1Turn = true;
  bool isGameOver = false;
  String winner = '';
  int tapCountSinceLastGrab = 0;

  Timer? _reactionTimer;
  bool _waitingForOpponentReaction = false;

  late final Future<void> Function([HapticsType? type]) _vibrate;
  bool _canVibrate = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ====================== Aktionen ======================

  void onTapChawan() {
    if (isGameOver || _waitingForOpponentReaction) return;

    tapCountSinceLastGrab++;
    _playSound('klack.mp3');
    _vibrateLight();

    // Zufalls-Umkippen
    if (tapCountSinceLastGrab > 12 && Random().nextDouble() < 0.05 + (tapCountSinceLastGrab - 12) * 0.015) {
      _endGame('random');
      return;
    }

    // Normaler Tap → Zug beendet, KI ist dran
    isPlayer1Turn = false;
    _waitingForOpponentReaction = false;
    notifyListeners();               // ← das fehlte!
    _kiMakesMove();
  }

  void onLongPressGrab() {
    if (isGameOver || _waitingForOpponentReaction) return;

    _playSound('schnapp.mp3');
    _vibrateMedium();

    isPlayer1Turn = false;
    _waitingForOpponentReaction = true;
    tapCountSinceLastGrab = 0;

    notifyListeners();               // ← wichtig!

    // KI hat jetzt genau 850 ms zum Reagieren
    _reactionTimer = Timer(const Duration(milliseconds: 850), () {
      if (_waitingForOpponentReaction) {
        _endGame('player1'); // KI zu langsam → Spieler 1 gewinnt
      }
    });

    _kiReactToGrab();
  }

  void onDoubleTapScreen() {
    if (! _waitingForOpponentReaction || isGameOver) {
      // Double-Tap außerhalb der Wartezeit → ignorieren oder Zufalls-Umkippen triggern
      return;
    }

    _waitingForOpponentReaction = false;
    _reactionTimer?.cancel();

    _playSound('toktok.mp3');
    _vibrateStrong();

    isPlayer1Turn = true;
    notifyListeners();               // ← Indicator wechselt zurück

    // KI ist wieder dran
    _kiMakesMove();
  }

  void newGame() {
    isPlayer1Turn = true;
    isGameOver = false;
    winner = '';
    tapCountSinceLastGrab = 0;
    _waitingForOpponentReaction = false;
    _reactionTimer?.cancel();
    notifyListeners();
  }

  // ====================== KI ======================

  void _kiMakesMove() async {
    await Future.delayed(Duration(milliseconds: 600 + Random().nextInt(600)));
    if (isGameOver) return;

    if (Random().nextDouble() < 0.75) {
      onTapChawan();                 // KI tippt meistens nur
    } else {
      onLongPressGrab();             // 25 % Chance, dass KI greift
    }
  }

  void _kiReactToGrab() async {
    await Future.delayed(Duration(milliseconds: 400 + Random().nextInt(400))); // 400–800 ms Reaktion
    if (! _waitingForOpponentReaction || isGameOver) return;

    // KI schafft es in ~80 % der Fälle
    if (Random().nextDouble() < 0.8) {
      onDoubleTapScreen();
    } else {
      // KI zu langsam → Spieler 1 gewinnt
      _endGame('player1');
    }
  }

  // ====================== Helfer ======================

  void _endGame(String who) {
    winner = who;
    isGameOver = true;
    _playSound('gong.mp3');
    _vibrateStrong();
    notifyListeners();
  }

  Future<void> _playSound(String file) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset('assets/audio/$file');
      await _audioPlayer.play();
    } catch (_) {}
  }

  void _vibrateLight() => _canVibrate ? _vibrate(HapticsType.light) : null;
  void _vibrateMedium() => _canVibrate ? _vibrate(HapticsType.medium) : null;
  void _vibrateStrong() => _canVibrate ? _vibrate(HapticsType.success) : null;

  @override
  void dispose() {
    _reactionTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}