// lib/services/beat_engine.dart
import 'dart:async';  // <--- DAS FEHLTE!
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matcha/core/constants.dart';

class BeatEngine {
  final AudioPlayer _player = AudioPlayer();
  Timer? _timer;
  late void Function() onBeat;

  // Exakte Beat-Timings (später perfektionieren)
  final List<int> konpiraBeatsMs = [0, 652, 1304, 1956, 2608, 3260, 3912, 4564, 5216, 5868];
  final List<int> matchaPonBeatsMs = [0, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500];

  Future<void> start(String variant) async {
    final beats = variant == 'konpira' ? konpiraBeatsMs : matchaPonBeatsMs;
    final asset = variant == 'konpira' ? soundKonpira : soundMatchaPon;

    await _player.setAsset(asset);
    await _player.setLoopMode(LoopMode.one);
    await _player.play();

    int beatIndex = 1;
    _timer = Timer.periodic(Duration(milliseconds: beats[beatIndex]), (_) {
      onBeat();
      beatIndex = (beatIndex + 1) % beats.length;
      if (beatIndex == 0) beatIndex = 1;
    });
  }

  Future<void> dispose() async {
    _timer?.cancel();
    await _player.stop();
    await _player.dispose();
  }
}

final beatEngineProvider = Provider<BeatEngine>((ref) => BeatEngine());