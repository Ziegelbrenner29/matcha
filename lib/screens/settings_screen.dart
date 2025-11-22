// lib/screens/settings_screen.dart
// ────────  KONPIRA SETTINGS – 22.11.2025 FINAL + DEBUG-MODE!  ────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konpira/providers/settings_provider.dart';
import 'package:konpira/providers/game_provider.dart';
import 'package:konpira/providers/bgm_provider.dart';

final _testMusicPlayingProvider = StateProvider<bool>((ref) => false);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    // ★★★★★ LIVE LAUTSTÄRKE FÜR BGM – ECHTZEIT! ★★★★★
    ref.listen<double>(settingsProvider.select((s) => s.masterVolume), (previous, next) {
      final bgmVol = ref.read(settingsProvider).bgmVolume;
      ref.read(bgmProvider).updateVolume(next * bgmVol);
    });

    ref.listen<double>(settingsProvider.select((s) => s.bgmVolume), (previous, next) {
      final masterVol = ref.read(settingsProvider).masterVolume;
      ref.read(bgmProvider).updateVolume(masterVol * next);
    });

    final isPlaying = ref.watch(_testMusicPlayingProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(gameProvider.notifier).stopMusic();
          ref.read(_testMusicPlayingProvider.notifier).state = false;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Einstellungen', style: TextStyle(color: Color(0xFF4A3728), fontSize: 28)),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(settings.theme.paperAsset),
              fit: BoxFit.cover,
              opacity: 0.6,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5F0E1), Color(0xFFE8DAB2)],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // ★★★★★ DER WUNDERSCHÖNE TITEL GANZ OBEN ★★★★★
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Image.asset(
                      'assets/images/konpira_title.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Scrollbereich
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Audio'),

                        _bambooSlider(
                          label: 'Master Lautstärke',
                          value: settings.masterVolume,
                          onChanged: notifier.updateMasterVolume,
                        ),
                        _bambooSlider(
                          label: 'Hintergrundmusik',
                          value: settings.bgmVolume,
                          onChanged: notifier.updateBgmVolume,
                        ),

                        // Gesang Test-Button
                        const SizedBox(height: 16),
                        const Text('Gesang (Konpira fune fune)', style: TextStyle(fontSize: 18, color: Color(0xFF4A3728))),
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPlaying ? Colors.red.shade700 : Colors.green.shade700,
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () async {
                              final newState = !isPlaying;
                              ref.read(_testMusicPlayingProvider.notifier).state = newState;
                              if (newState) {
                                await ref.read(gameProvider.notifier).startMusic('konpira');
                              } else {
                                ref.read(gameProvider.notifier).stopMusic();
                              }
                            },
                            child: Text(
                              isPlaying ? 'Stop Gesang' : 'Test Konpira Gesang',
                              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        _bambooSlider(
                          label: 'Soundeffekte (tok/pon/DON!)',
                          value: settings.sfxVolume,
                          onChanged: notifier.updateSfxVolume,
                        ),
                        _bambooSliderInt(
                          label: 'Haptics Intensität',
                          value: settings.hapticsIntensity.toDouble(),
                          min: 0,
                          max: 3,
                          divisions: 3,
                          labels: const ['Aus', 'Leicht', 'Mittel', 'Stark'],
                          onChanged: (v) => notifier.updateHapticsIntensity(v.round()),
                        ),

                        const SizedBox(height: 32),
                        _sectionTitle('Gameplay'),

                        // PvP Sitzposition
                        const Text('Spieler-Anordnung (PvP)', style: TextStyle(fontSize: 18, color: Color(0xFF4A3728))),
                        const SizedBox(height: 8),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: true, label: Text('Gegenüber'), icon: Icon(Icons.people)),
                            ButtonSegment(value: false, label: Text('Nebeneinander'), icon: Icon(Icons.event_seat)),
                          ],
                          selected: {settings.playersFaceEachOther},
                          onSelectionChanged: (set) => notifier.updatePlayersFaceEachOther(set.first),
                        ),
                        const SizedBox(height: 24),

                        // Max Fake-Outs
                        const Text('Max Fake-Outs in Folge', style: TextStyle(fontSize: 18, color: Color(0xFF4A3728))),
                        const SizedBox(height: 8),
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 1, label: Text('1')),
                            ButtonSegment(value: 2, label: Text('2')),
                            ButtonSegment(value: 3, label: Text('3')),
                          ],
                          selected: {settings.maxFakesInARow.clamp(1, 3)},
                          onSelectionChanged: (set) => notifier.updateMaxFakesInARow(set.first),
                        ),
                        const SizedBox(height: 24),

                        // Schwierigkeitsstufe
                        const Text('Schwierigkeitsstufe', style: TextStyle(fontSize: 18, color: Color(0xFF4A3728))),
                        const SizedBox(height: 8),
                        SegmentedButton<GameDifficulty>(
                          segments: const [
                            ButtonSegment(value: GameDifficulty.easy, label: Text('Easy')),
                            ButtonSegment(value: GameDifficulty.normal, label: Text('Normal')),
                            ButtonSegment(value: GameDifficulty.hard, label: Text('Hard')),
                          ],
                          selected: {settings.gameDifficulty},
                          onSelectionChanged: (set) => notifier.updateGameDifficulty(set.first),
                        ),
                        const SizedBox(height: 24),

                        // Speed-Up pro Runde
                        SwitchListTile(
                          title: const Text('Beschleunigung pro Runde', style: TextStyle(fontSize: 18, color: Color(0xFF4A3728))),
                          subtitle: const Text('Startet bei gewählter Stufe und wird immer schneller – Chaos-Zen!'),
                          value: settings.speedUpPerRound,
                          activeColor: const Color(0xFF8B9F7A),
                          onChanged: notifier.updateSpeedUpPerRound,
                        ),
                        const SizedBox(height: 24),

                        // Timing-Fenster
                        _bambooSliderInt(
                          label: 'Timing-Fenster (±ms)',
                          value: settings.timingWindowMs.toDouble(),
                          min: 50,
                          max: 120,
                          divisions: 7,
                          onChanged: (v) => notifier.updateTimingWindowMs(v.round()),
                        ),

                        // KI Platzhalter
                        _aiDifficultyPlaceholder(settings.aiDifficulty),

                        const SizedBox(height: 32),
                        _sectionTitle('Visuals'),

                        // Theme-Wechsler
                        ...AppTheme.values.map((theme) {
                          final isSelected = settings.theme == theme;
                          final icon = switch (theme) {
                            AppTheme.washiClassic => Icons.auto_stories,
                            AppTheme.matchaGarden => Icons.local_florist,
                            AppTheme.goldenTemple => Icons.account_balance,
                          };

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? const Color(0xFF8B9F7A) : Colors.transparent,
                                foregroundColor: isSelected ? Colors.white : const Color(0xFF4A3728),
                                elevation: isSelected ? 8 : 2,
                                shadowColor: isSelected ? Colors.green.shade900 : Colors.black26,
                                side: BorderSide(color: const Color(0xFF8B9F7A), width: isSelected ? 3 : 1),
                                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              onPressed: () {
                                notifier.setTheme(theme);
                                ref.read(bgmProvider).updateThemeAndPlayIfAllowed();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(icon, size: 36, color: isSelected ? Colors.white : const Color(0xFF8B9F7A)),
                                  const SizedBox(width: 20),
                                  Column(
                                    children: [
                                      Text(
                                        theme.displayName.split(' ').first,
                                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF4A3728)),
                                      ),
                                      Text(
                                        theme.displayName.split(' ').last,
                                        style: TextStyle(fontSize: 16, color: isSelected ? Colors.white70 : const Color(0xFF4A3728)),
                                      ),
                                    ],
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 20),
                                    const Icon(Icons.check_circle, color: Colors.white, size: 36),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),

                        _bambooSlider(
                          label: 'Animations-Intensität',
                          value: settings.animationIntensity,
                          onChanged: notifier.updateAnimationIntensity,
                        ),

                        // ★★★★★ NEU: DEBUG-MODE TOGGLE ★★★★★
                        const SizedBox(height: 48),
                        _sectionTitle('🛠️ Entwickler'),
                        
                        SwitchListTile(
                          title: const Text(
                            'Debug-Modus',
                            style: TextStyle(fontSize: 18, color: Color(0xFF4A3728), fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            settings.debugMode 
                              ? '✅ Debug-Button auf HomeScreen sichtbar' 
                              : 'Aktiviere den Debug-Modus für Entwickler-Tools',
                            style: TextStyle(
                              color: settings.debugMode ? Colors.green.shade700 : const Color(0xFF4A3728),
                              fontWeight: settings.debugMode ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          value: settings.debugMode,
                          activeColor: Colors.greenAccent.shade700,
                          onChanged: notifier.updateDebugMode,
                        ),

                        const SizedBox(height: 48),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _showResetDialog(context),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade300),
                            child: const Text('Highscores zurücksetzen', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────── HILFSWIDGETS ───────
  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(top: 32, bottom: 16),
        child: Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF4A3728))),
      );

  Widget _bambooSlider({
    required String label,
    required double value,
    required void Function(double) onChanged,
  }) => _SliderTile(label: label, value: value, onChanged: onChanged);

  Widget _bambooSliderInt({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    List<String>? labels,
    required void Function(double) onChanged,
  }) => _SliderTile(
        label: label,
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        labels: labels,
        onChanged: onChanged,
      );

  Widget _aiDifficultyPlaceholder(int value) => Opacity(
        opacity: 0.5,
        child: _bambooSliderInt(
          label: 'KI-Schwierigkeit (bald!)',
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          labels: const ['Zen-Schüler', 'Schüler', 'Meister', 'Großmeister', 'Unmöglich'],
          onChanged: (_) {},
        ),
      );

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Highscores zurücksetzen?'),
        content: const Text('Das kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Löschen', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}

// Custom Bamboo-Slider Widget
class _SliderTile extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final List<String>? labels;
  final void Function(double) onChanged;

  const _SliderTile({
    required this.label,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 18, color: Color(0xFF4A3728))),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(height: 12, color: const Color(0xFF8B9F7A).withOpacity(0.3)),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 12,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
                  activeTrackColor: const Color(0xFF8B9F7A),
                  inactiveTrackColor: const Color(0xFF8B9F7A).withOpacity(0.3),
                  thumbColor: const Color(0xFF4A3728),
                ),
                child: Slider(
                  value: value.clamp(min, max),
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: labels != null ? labels![value.round().clamp(0, labels!.length - 1)] : null,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}