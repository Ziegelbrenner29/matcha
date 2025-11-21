// lib/providers/settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTheme {
  washiClassic,
  matchaGarden,
  goldenTemple,
}

extension AppThemeExtension on AppTheme {
  String get paperAsset => 'assets/images/themes/paper_${index + 1}.png';
  String get bambooAsset => 'assets/images/themes/bamboo_track_${index + 1}.png';
  String get chawanAsset => switch (this) {
    AppTheme.washiClassic => 'assets/images/themes/chawan_beige.png',
    AppTheme.matchaGarden => 'assets/images/themes/chawan_green.png',
    AppTheme.goldenTemple => 'assets/images/themes/chawan_black.png',
  };

  String get displayName => switch (this) {
    AppTheme.washiClassic => '和紙古典 Washi Classic',
    AppTheme.matchaGarden => '抹茶庭園 Matcha Garden',
    AppTheme.goldenTemple => '金寺 Golden Temple',
  };
}

class AppSettings {
  final double masterVolume;
  final double bgmVolume;
  final bool voiceEnabled;
  final double sfxVolume;
  final int hapticsIntensity;
  final int aiDifficulty;
  final int maxFakesInARow;
  final int timingWindowMs;
  final double animationIntensity;
  final AppTheme theme;

  const AppSettings({
    this.masterVolume = 0.8,
    this.bgmVolume = 0.6,
    this.voiceEnabled = true,
    this.sfxVolume = 1.0,
    this.hapticsIntensity = 2,
    this.aiDifficulty = 3,
    this.maxFakesInARow = 2,
    this.timingWindowMs = 80,
    this.animationIntensity = 1.0,
    this.theme = AppTheme.washiClassic,
  });

  AppSettings copyWith({
    double? masterVolume,
    double? bgmVolume,
    bool? voiceEnabled,
    double? sfxVolume,
    int? hapticsIntensity,
    int? aiDifficulty,
    int? maxFakesInARow,
    int? timingWindowMs,
    double? animationIntensity,
    AppTheme? theme,
  }) {
    return AppSettings(
      masterVolume: masterVolume ?? this.masterVolume,
      bgmVolume: bgmVolume ?? this.bgmVolume,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      hapticsIntensity: hapticsIntensity ?? this.hapticsIntensity,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      maxFakesInARow: maxFakesInARow ?? this.maxFakesInARow,
      timingWindowMs: timingWindowMs ?? this.timingWindowMs,
      animationIntensity: animationIntensity ?? this.animationIntensity,
      theme: theme ?? this.theme,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

final _testMusicPlayingProvider = StateProvider<bool>((ref) => false);

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  void updateMasterVolume(double v) => state = state.copyWith(masterVolume: v);
  void updateBgmVolume(double v) => state = state.copyWith(bgmVolume: v);
  void updateVoiceEnabled(bool v) => state = state.copyWith(voiceEnabled: v);
  void updateSfxVolume(double v) => state = state.copyWith(sfxVolume: v);
  void updateHapticsIntensity(int v) => state = state.copyWith(hapticsIntensity: v);
  void updateTimingWindowMs(int v) => state = state.copyWith(timingWindowMs: v);
  void updateMaxFakesInARow(int v) => state = state.copyWith(maxFakesInARow: v);
  void updateAnimationIntensity(double v) => state = state.copyWith(animationIntensity: v);
  void setTheme(AppTheme theme) => state = state.copyWith(theme: theme);
}