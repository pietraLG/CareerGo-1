import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OndaFundo extends StatelessWidget {
  final double altura;
  final bool forte;

  const OndaFundo({super.key, this.altura = 200, this.forte = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: altura,
      child: CustomPaint(painter: _OndaPainter(forte)),
    );
  }
}

class _OndaPainter extends CustomPainter {
  final bool forte;
  _OndaPainter(this.forte);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final area = Rect.fromLTWH(0, 0, w, h);

    // Onda de trás (mais clara)
    final tras = Path()
      ..moveTo(0, h * 0.40)
      ..cubicTo(w * 0.25, h * 0.00, w * 0.55, h * 0.80, w, h * 0.30)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    // Onda da frente
    final frente = Path()
      ..moveTo(0, h * 0.70)
      ..cubicTo(w * 0.30, h * 0.35, w * 0.60, h * 1.00, w, h * 0.60)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final alfaTras = forte ? 110 : 40;
    final alfaFrente = forte ? 220 : 80;

    canvas.drawPath(
      tras,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.roxo.withAlpha(alfaTras),
            AppColors.azul.withAlpha(alfaTras),
          ],
        ).createShader(area),
    );
    canvas.drawPath(
      frente,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.roxo.withAlpha(alfaFrente),
            AppColors.azul.withAlpha(alfaFrente),
          ],
        ).createShader(area),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}