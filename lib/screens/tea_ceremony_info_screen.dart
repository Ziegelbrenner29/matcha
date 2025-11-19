// lib/screens/tea_ceremony_info_screen.dart
import 'package:flutter/material.dart';

class TeaCeremonyInfoScreen extends StatelessWidget {
  const TeaCeremonyInfoScreen({super.key});

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
          'Die Teezeremonie',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'Chanoyu – die japanische Teezeremonie\n\n'
            'Harmonie, Respekt, Reinheit und Ruhe.\n\n'
            'Matcha-pon ist ein traditionelles Trinkspiel,\n'
            'das nach der Zeremonie gespielt wird.\n\n'
            'Wir digitalisieren es mit höchstem Respekt\n'
            'vor der Kultur und dem Zen-Geist.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, height: 1.8, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}