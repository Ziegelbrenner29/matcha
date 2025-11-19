// lib/screens/credits_screen.dart
import 'package:flutter/material.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Credits',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Matcha\n',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: Color(0xFF98BF8A)),
            ),
            Text(
              'Ein digitales Tee-Trinkspiel\n'
              'mit höchstem Respekt vor der japanischen Teezeremonie.\n\n'
              'Entwickelt mit viel ☯ und Flutter\n'
              'von Ziegelbrenner29\n\n'
              'Rive-Animationen, Sounds & Haptik: in Liebe selbst gemacht\n'
              'Musik: lizenzfreie traditionelle Stücke\n\n'
              'Danke, dass du dabei bist.\n'
              'Namaste & guten Tee!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, height: 1.8, color: Colors.black87),
            ),
            SizedBox(height: 60),
            Text(
              'Version 1.0.0 – Einmalkauf 1,99 €',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}