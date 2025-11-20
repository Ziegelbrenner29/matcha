// lib/main.dart
void main() {
  async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matcha',
      home: const SplashScreen(), // ← startet direkt mit deinem Splash
    );
  }
}