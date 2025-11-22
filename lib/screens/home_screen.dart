// lib/screens/home_screen.dart
// ────────  KONPIRA HOME SCREEN – 22.11.2025 MIT HIGHSCORE + DEBUG-BUTTON!  ────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konpira/screens/game_screen.dart';
import 'package:konpira/screens/settings_screen.dart';
import 'package:konpira/screens/info_screen.dart';
import 'package:konpira/screens/credits_screen.dart';
import 'package:konpira/screens/highscore_screen.dart';
import 'package:konpira/screens/debug_screen.dart'; // ← NEU!
import 'package:konpira/providers/settings_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String? _selectedVariant;
  late AnimationController _splitController;
  late Animation<double> _splitAnimation;

  @override
  void initState() {
    super.initState();
    _splitController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _splitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _splitController, curve: Curves.easeOutCubic),
    );
  }

  void _selectVariant(String variant) {
    setState(() => _selectedVariant = variant);
    _splitController.forward();
  }

  void _startGame(BuildContext context, bool isVsKI) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
    _splitController.reverse().then((_) => setState(() => _selectedVariant = null));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final settings = ref.watch(settingsProvider);
      final theme = settings.theme;
      final debugMode = settings.debugMode;  // ← NEU: Debug-Mode prüfen

      return Scaffold(
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
            child: Stack(
              children: [
                // Titel
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 56),
                    child: Image.asset(
                      'assets/images/konpira_title.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Hauptinhalt
                Padding(
                  padding: const EdgeInsets.only(top: 180),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Game-Buttons
                      _buildVariantButton('Konpira fune fune', 'konpira'),
                      const SizedBox(height: 40),
                      _buildVariantButton('Matcha pon!', 'matchapon'),

                      const SizedBox(height: 60),

                      // Highscore-Button
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const HighscoreScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B9F7A).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                          ),
                          child: const Text(
                            'Highscores',
                            style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      // ★★★★★ NEU: DEBUG-BUTTON (nur sichtbar wenn Debug-Mode AN) ★★★★★
                      if (debugMode) ...[
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const DebugScreen()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.greenAccent, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.5),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.bug_report, color: Colors.greenAccent, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  'Debug Console',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const Spacer(flex: 3),

                      // Footer
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            _FooterIcon(icon: Icons.settings, screen: SettingsScreen()),
                            SizedBox(width: 40),
                            _FooterIcon(icon: Icons.info_outline, screen: InfoScreen()),
                            SizedBox(width: 40),
                            _FooterIcon(icon: Icons.favorite_outline, screen: CreditsScreen()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildVariantButton(String title, String variant) {
    final isSelected = _selectedVariant == variant;

    return GestureDetector(
      onTap: () => isSelected ? null : _selectVariant(variant),
      child: AnimatedBuilder(
        animation: _splitAnimation,
        builder: (context, child) {
          if (!isSelected || _splitAnimation.value == 0) {
            return _normalButton(title);
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _splitHalf('vs Zen-Meister', true, variant),
              _splitHalf('vs Freund', false, variant),
            ],
          );
        },
      ),
    );
  }

  Widget _normalButton(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFBC9F7A),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6))],
      ),
      child: Text(title, style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _splitHalf(String text, bool isLeft, String variant) {
    final progress = _splitAnimation.value;

    final double baseWidth = 160.0;
    final double extra = progress * 40.0;
    final double maxAvailable = (MediaQuery.of(context).size.width - 80) / 2;
    final double width = (baseWidth + extra).clamp(0.0, maxAvailable);

    return GestureDetector(
      onTap: () => _startGame(context, isLeft),
      child: ClipRRect(
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(40) : Radius.zero,
          right: isLeft ? Radius.zero : const Radius.circular(40),
        ),
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          color: Color.lerp(const Color(0xFFBC9F7A), const Color(0xFF8B6F47), isLeft ? 0.0 : progress),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _splitController.dispose();
    super.dispose();
  }
}

// FooterIcon
class _FooterIcon extends StatelessWidget {
  final IconData icon;
  final Widget screen;

  const _FooterIcon({required this.icon, required this.screen});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0x33BC9F7A),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 32, color: Color(0xFF4A3728)),
      ),
    );
  }
}