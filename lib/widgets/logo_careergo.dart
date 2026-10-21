import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LogoCareerGo extends StatelessWidget {
  final double tamanhoIcone;
  final double tamanhoTexto;
  final bool vertical;

  const LogoCareerGo({
    super.key,
    this.tamanhoIcone = 36,
    this.tamanhoTexto = 30,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    // ShaderMask pinta o ícone com o degradê
    final icone = ShaderMask(
      shaderCallback: (area) => AppColors.degrade.createShader(area),
      child: Icon(
        Icons.rocket_launch_rounded,
        size: tamanhoIcone,
        color: Colors.white,
      ),
    );

    final texto = Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: tamanhoTexto,
          fontWeight: FontWeight.w800,
        ),
        children: [
          const TextSpan(
            text: 'Career',
            style: TextStyle(color: AppColors.texto),
          ),
          TextSpan(
            text: 'Go',
            style: TextStyle(
              foreground: Paint()
                ..shader = AppColors.degrade.createShader(
                  Rect.fromLTWH(0, 0, tamanhoTexto * 1.6, tamanhoTexto),
                ),
            ),
          ),
        ],
      ),
    );

    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [icone, const SizedBox(height: 8), texto],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [icone, const SizedBox(width: 8), texto],
    );
  }
}