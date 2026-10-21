import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Necessário antes de usar o Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CareerGoApp());
}

class CareerGoApp extends StatelessWidget {
  const CareerGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareerGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      home: const SplashScreen(),
    );
  }
}