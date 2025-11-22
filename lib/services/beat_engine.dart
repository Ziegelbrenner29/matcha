// lib/services/beat_engine.dart

import 'dart:async';
import 'package:flutter/foundation.dart';

class BeatState {
  final int currentBpm;
  final int beatCount;
  final bool isRunning;

  const BeatState({
    required this.currentBpm,
    required this.beatCount,
    required this.isRunning,
  });

  factory BeatState.initial() => const BeatState(
        currentBpm: 0,
        beatCount: 0,
        isRunning: false,
      );

  BeatState copyWith({
    int? currentBpm,
    int? beatCount,
    bool? isRunning,
  }) {
    return BeatState(
      currentBpm: currentBpm ?? this.currentBpm,
      beatCount: beatCount ?? this.beatCount,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class BeatEngine extends ChangeNotifier {
  BeatState _state = BeatState.initial();
  Timer? _beatTimer;
  bool _disposed = false;  // ← NEU: Disposed-Flag

  void Function()? onBeat;

  BeatState get state => _state;

  void start(int bpm) {
    _beatTimer?.cancel();
    
    final intervalMs = (60000 / bpm).round();
    
    _state = BeatState(
      currentBpm: bpm,
      beatCount: 0,
      isRunning: true,
    );
    
    _safeNotifyListeners();  // ← Sichere Variante
    debugPrint('🥁 BeatEngine gestartet: $bpm BPM (${intervalMs}ms Intervall)');

    _beatTimer = Timer.periodic(
      Duration(milliseconds: intervalMs),
      (_) {
        if (_disposed) {  // ← Prüfe ob disposed
          _beatTimer?.cancel();
          return;
        }
        
        _state = _state.copyWith(beatCount: _state.beatCount + 1);
        _safeNotifyListeners();  // ← Sichere Variante
        onBeat?.call();
        debugPrint('🥁 Beat #${_state.beatCount} @ ${_state.currentBpm} BPM');
      },
    );
  }

  void updateBpm(int newBpm) {
    if (!_state.isRunning || _disposed) return;
    
    final intervalMs = (60000 / newBpm).round();
    
    _state = _state.copyWith(currentBpm: newBpm);
    _safeNotifyListeners();  // ← Sichere Variante
    
    _beatTimer?.cancel();
    _beatTimer = Timer.periodic(
      Duration(milliseconds: intervalMs),
      (_) {
        if (_disposed) {  // ← Prüfe ob disposed
          _beatTimer?.cancel();
          return;
        }
        
        _state = _state.copyWith(beatCount: _state.beatCount + 1);
        _safeNotifyListeners();  // ← Sichere Variante
        onBeat?.call();
        debugPrint('🥁 Beat #${_state.beatCount} @ ${_state.currentBpm} BPM');
      },
    );
    
    debugPrint('⚡ BeatEngine Speed-Up: $newBpm BPM (${intervalMs}ms)');
  }

  void stop() {
    _beatTimer?.cancel();
    _state = _state.copyWith(isRunning: false);
    _safeNotifyListeners();  // ← Sichere Variante
    debugPrint('🛑 BeatEngine gestoppt');
  }

  // ★★★★★ SICHERE notifyListeners() - ruft nur auf wenn nicht disposed ★★★★★
  void _safeNotifyListeners() {
    if (!_disposed && hasListeners) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;  // ← Markiere als disposed
    _beatTimer?.cancel();
    super.dispose();
    debugPrint('🗑️ BeatEngine disposed');
  }
}