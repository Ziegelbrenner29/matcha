// lib/services/haptics_service.dart
import 'package:haptic_feedback/haptic_feedback.dart';

class HapticsService {
  // In Version 0.4.2 gibt's keinen Konstruktor – alles static!
  static Future<void> light() async {
    try {
      await Haptics.vibrate(HapticsType.light);
    } catch (_) {}
  }

  static Future<void> medium() async {
    try {
      await Haptics.vibrate(HapticsType.medium);
    } catch (_) {}
  }

  static Future<void> heavy() async {
    try {
      await Haptics.vibrate(HapticsType.heavy);
    } catch (_) {}
  }
}