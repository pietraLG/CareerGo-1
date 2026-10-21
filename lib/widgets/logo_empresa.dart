  import 'package:flutter/material.dart';

class LogoEmpresa extends StatelessWidget {
  final String nome;
  final double tamanho;

  const LogoEmpresa({super.key, required this.nome, this.tamanho = 48});

  static const _cores = [
    Color(0xFF7B4DFF),
    Color(0xFF3B82F6),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
  ];

  @override
  Widget build(BuildContext context) {
    final limpo = nome.trim();
    final inicial = limpo.isEmpty ? '?' : limpo[0].toUpperCase();
    // Soma as letras do nome para escolher sempre a mesma cor
    final soma = limpo.codeUnits.fold<int>(0, (a, b) => a + b);
    final cor = _cores[soma % _cores.length];

    return Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cor.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        inicial,
        style: TextStyle(
          color: cor,
          fontWeight: FontWeight.bold,
          fontSize: tamanho * 0.42,
        ),
      ),
    );
  }
}