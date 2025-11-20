// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:matcha/screens/game_screen.dart';
import 'package:matcha/screens/settings_screen.dart';
import 'package:matcha/screens/info_screen.dart';
import 'package:matcha/screens/credits_screen.dart';

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
      MaterialPageRoute(
        builder: (_) => GameScreen(variant: _selectedVariant!, isVsKI: isVsKI),
      ),
    );
    _splitController.reverse().then((_) => setState(() => _selectedVariant = null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F0E1), Color(0xFFE8DAB2)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Text(
                    'Matcha',
                    style: TextStyle(fontSize: 72, fontFamily: 'Zen', color: Color(0xFF4A3728)),
                  ),
                ),
              ),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildVariantButton('Konpira fune fune', 'konpira'),
                    const SizedBox(height: 40),
                    _buildVariantButton('Matcha pon!', 'matchapon'),
                  ],
                ),
              ),

              // Footer – jetzt wieder mit const (dank _FooterIcon + const in Screens)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
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
              ),
            ],
          ),
        ),
      ),
    );
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
    final width = 180.0 + (progress * 60);

    return GestureDetector(
      onTap: () => _startGame(context, isLeft),
      child: ClipRRect(
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(40) : Radius.zero,
          right: isLeft ? Radius.zero : const Radius.circular(40),
        ),
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 24),
          color: Color.lerp(const Color(0xFFBC9F7A), const Color(0xFF8B6F47), isLeft ? 0.0 : progress),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w600),
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

// Private Footer-Icon Widget – außerhalb der State-Klasse!
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