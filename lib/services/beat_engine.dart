// lib/services/beat_engine.dart
// ────────  KONPIRA BEAT ENGINE – 22.11.2025 NUR ONBEAT EDITION (Lied bleibt bei GameNotifier!)  ────────

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konpira/providers/settings_provider.dart';

class BeatEngine {
  Timer? _beatTimer;
  late void Function() onBeat;
  double _currentIntervalMs = 652.0;

  void start(Ref ref) {
    final settings = ref.read(settingsProvider);
    _currentIntervalMs = settings.gameDifficulty.baseBeatIntervalMs;

    // Exakter Timer – kein Drift, weil nur für onBeat, kein Audio-Player!
    _beatTimer?.cancel();
    _beatTimer = Timer.periodic(Duration(milliseconds: _currentIntervalMs.round()), (_) {
      onBeat();
    });
  }

  // Für Speed-Up-Chaos später!
  void setSpeed(double speed) {
    // Später: Timer neu starten mit _currentIntervalMs / speed
  }

  void updateInterval(double newIntervalMs) {
    _currentIntervalMs = newIntervalMs;
    // Timer neu starten
    _beatTimer?.cancel();
    _beatTimer = Timer.periodic(Duration(milliseconds: _currentIntervalMs.round()), (_) {
      onBeat();
    });
  }

  void dispose() {
    _beatTimer?.cancel();
  }
}

final beatEngineProvider = Provider<BeatEngine>((ref) => BeatEngine());