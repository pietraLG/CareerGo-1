import 'package:flutter/material.dart';
import 'app_colors.dart';

// Define o estilo geral do app (fundo, campos de texto, barra do topo).
class AppTheme {
  static ThemeData get claro {
    // Borda arredondada usada nos campos de texto
    OutlineInputBorder borda(Color cor, [double largura = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cor, width: largura),
      );
    }

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.fundo,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.roxo),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fundo,
        foregroundColor: AppColors.texto,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.superficie,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.textoSuave),
        border: borda(AppColors.borda),
        enabledBorder: borda(AppColors.borda),
        focusedBorder: borda(AppColors.roxo, 1.5),
      ),
    );
  }
}