// lib/providers/beat_engine_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konpira/services/beat_engine.dart';

final beatEngineProvider = ChangeNotifierProvider<BeatEngine>((ref) {
  return BeatEngine();
});