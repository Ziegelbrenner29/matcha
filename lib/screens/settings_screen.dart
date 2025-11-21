// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matcha/main.dart';  // <<< routeObserver!
import 'package:matcha/providers/settings_provider.dart';
import 'package:matcha/providers/game_provider.dart';

final _testMusicPlayingProvider = StateProvider<bool>((ref) => false);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    // Wird aufgerufen, wenn Settings verlassen wird (Back-Button, pop, etc.)
    ref.read(gameProvider.notifier).stopMusic();
    ref.read(_testMusicPlayingProvider.notifier).state = false;
    debugPrint('🎶 Settings verlassen – Gesang gestoppt + Button zurückgesetzt');
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final isPlaying = ref.watch(_testMusicPlayingProvider);

    return Scaffold(
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

                // <<< Gesang Test/Stop-Button – perfekt Toggle + Auto-Stop!
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
                _bambooSliderInt(
                  label: 'Timing-Fenster (±ms)',
                  value: settings.timingWindowMs.toDouble(),
                  min: 50,
                  max: 120,
                  divisions: 7,
                  onChanged: (v) => notifier.updateTimingWindowMs(v.round()),
                ),
                _segmentedFakes(notifier, settings.maxFakesInARow),
                _aiDifficultyPlaceholder(settings.aiDifficulty),

                const SizedBox(height: 32),
                _sectionTitle('Visuals'),

                // <<< Theme-Wechsler mit großen Buttons + Kanji + Romaji + Icon
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
                      onPressed: () => notifier.setTheme(theme),
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
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 24),
        child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A3728))),
      );

  Widget _bambooSlider({
    required String label,
    required double value,
    required void Function(double) onChanged,
  }) =>
      _SliderTile(label: label, value: value, onChanged: onChanged);

  Widget _bambooSliderInt({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    List<String>? labels,
    required void Function(double) onChanged,
  }) =>
      _SliderTile(
        label: label,
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        labels: labels,
        onChanged: onChanged,
      );

  Widget _switchTile({
    required String title,
    required bool value,
    required void Function(bool) onChanged,
  }) =>
      ListTile(
        title: Text(title, style: const TextStyle(fontSize: 18, color: Color(0xFF4A3728))),
        trailing: Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF8B9F7A)),
      );

  Widget _segmentedFakes(SettingsNotifier notifier, int current) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Max Fake-Outs in Folge', style: TextStyle(fontSize: 18, color: Color(0xFF4A3728))),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1')),
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 99, label: Text('∞')),
              ],
              selected: {current == 99 ? 99 : current},
              onSelectionChanged: (Set<int> newSelection) {
                final val = newSelection.first;
                notifier.updateMaxFakesInARow(val == 99 ? 99 : val);
              },
            ),
          ],
        ),
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