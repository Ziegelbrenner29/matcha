// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konpira/screens/home_screen.dart';

/// Globaler RouteObserver – für Auto-Stop beim Verlassen von Settings!
final routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Immer Portrait (hochkant) erzwingen
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: MatchaApp()));
}

class MatchaApp extends ConsumerWidget {
  const MatchaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Matcha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Zen',
        scaffoldBackgroundColor: const Color(0xFFF5F0E1),
      ),
      home: const HomeScreen(),
      navigatorObservers: [routeObserver],  // <<< HIER REIN – Auto-Stop aktiviert!
    );
  }
}