// lib/screens/debug_screen.dart
// ────────  KONPIRA DEBUG SCREEN – FÜR ENTWICKLER  ────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konpira/providers/settings_provider.dart';
import 'package:konpira/providers/beat_engine_provider.dart';
import 'package:konpira/providers/game_provider.dart';
import 'package:konpira/models/game_state.dart';

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final beatEngine = ref.watch(beatEngineProvider);
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛠️ Debug Console'),
        backgroundColor: Colors.black87,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _debugSection(
                title: '🎵 BeatEngine State',
                children: [
                  _debugRow('BPM', '${beatEngine.state.currentBpm}'),
                  _debugRow('Beat Count', '${beatEngine.state.beatCount}'),
                  _debugRow('Is Running', '${beatEngine.state.isRunning}'),
                ],
              ),

              _debugSection(
                title: '🎮 Game State',
                children: [
                  _debugRow('Phase', gameState.phase.name),
                  _debugRow('Player 1 Turn', '${gameState.isPlayer1Turn}'),
                  _debugRow('Bowl Owner', gameState.bowlOwner.name),
                  _debugRow('Fake Count', '${gameState.fakeCount}'),
                  _debugRow('Winner', gameState.winner.isEmpty ? 'None' : gameState.winner),
                ],
              ),

              _debugSection(
                title: '⚙️ Settings',
                children: [
                  _debugRow('Theme', settings.theme.displayName),
                  _debugRow('Difficulty', settings.gameDifficulty.name),
                  _debugRow('Speed-Up', '${settings.speedUpPerRound}'),
                  _debugRow('Players Face Each Other', '${settings.playersFaceEachOther}'),
                  _debugRow('Timing Window', '${settings.timingWindowMs}ms'),
                  _debugRow('Max Fakes', '${settings.maxFakesInARow}'),
                  _debugRow('Animation Intensity', '${settings.animationIntensity}'),
                ],
              ),

              _debugSection(
                title: '🔊 Audio',
                children: [
                  _debugRow('Master Volume', '${(settings.masterVolume * 100).round()}%'),
                  _debugRow('BGM Volume', '${(settings.bgmVolume * 100).round()}%'),
                  _debugRow('SFX Volume', '${(settings.sfxVolume * 100).round()}%'),
                  _debugRow('Voice Enabled', '${settings.voiceEnabled}'),
                ],
              ),

              _debugSection(
                title: '📱 Device Info',
                children: [
                  _debugRow('Platform', Theme.of(context).platform.name),
                  _debugRow('Screen Size', '${MediaQuery.of(context).size.width.round()} x ${MediaQuery.of(context).size.height.round()}'),
                  _debugRow('Pixel Ratio', '${MediaQuery.of(context).devicePixelRatio}'),
                ],
              ),

              const SizedBox(height: 24),
              
              // Quick Actions
              Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => ref.read(gameProvider.notifier).resetGame(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Game'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        final notifier = ref.read(settingsProvider.notifier);
                        notifier.updateDebugMode(false);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.bug_report_outlined),
                      label: const Text('Exit Debug Mode'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _debugSection({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _debugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}