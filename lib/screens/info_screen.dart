// lib/screens/info_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konpira/providers/settings_provider.dart';

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(settingsProvider).theme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Teezeremonie Info', style: TextStyle(color: Color(0xFF4A3728), fontSize: 28)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(theme.paperAsset),
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
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const SizedBox(height: 80), // Platz für AppBar
                Text(
                  'Konpira fune fune',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF4A3728)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ein traditionelles japanisches Trinkspiel aus Shikoku, basierend auf dem Pilgerlied zum Kotohira-gū-Schrein (Konpira-san). '
                  'Zwei Spieler klopfen abwechselnd auf Tisch oder Schale im Rhythmus des Gesangs – wer das Timing verpasst oder falsch klopft, verliert!\n\n'
                  'In Matcha: Ein-Finger-Tap = tok/pon, Zwei-Finger-Double-Tap = DON!, Pinch/LongPress = Schale hochheben + Fake-Out möglich (max. 2x).\n\n'
                  'Der Gewinner trinkt die Schale Matcha leer – oder zwingt den Verlierer dazu! 🍵\n\n'
                  '„Hoi-hoi!“ – viel Spaß beim Pilgern!',
                  style: TextStyle(fontSize: 18, height: 1.6, color: Color(0xFF4A3728)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}