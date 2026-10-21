import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/logo_careergo.dart';
import '../widgets/onda_fundo.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Espera 3 segundos e troca para o login
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return; // se a tela já saiu, não faz nada
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.superficie,
      body: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: OndaFundo(altura: 320, forte: true),
          ),
          Align(
            alignment: const Alignment(0, -0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                LogoCareerGo(
                  vertical: true,
                  tamanhoIcone: 96,
                  tamanhoTexto: 44,
                ),
                SizedBox(height: 16),
                Text(
                  'Organize sua carreira.\nAcompanhe suas oportunidades.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.texto,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}