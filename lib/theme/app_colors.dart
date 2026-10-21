import 'package:flutter/material.dart';

// Todas as cores do CareerGo ficam aqui, num lugar só.
class AppColors {
  // Cores principais (o degradê roxo -> azul do design)
  static const Color roxo = Color(0xFF7B4DFF);
  static const Color azul = Color(0xFF4DA3FF);

  static const LinearGradient degrade = LinearGradient(
    colors: [roxo, azul],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Cores de fundo, texto e borda
  static const Color fundo = Color(0xFFF4F7FF);
  static const Color superficie = Colors.white;
  static const Color texto = Color(0xFF1B1B3A);
  static const Color textoSuave = Color(0xFF8A8FA8);
  static const Color borda = Color(0xFFE6E9F5);

  // Cores dos 6 status (as mesmas do seu protótipo)
  static const Color statusEnviada = Color(0xFF3B82F6);
  static const Color statusAnalise = Color(0xFFF59E0B);
  static const Color statusEntrevista = Color(0xFF8B5CF6);
  static const Color statusTeste = Color(0xFFF97316);
  static const Color statusAprovado = Color(0xFF22C55E);
  static const Color statusRejeitado = Color(0xFFEF4444);
}