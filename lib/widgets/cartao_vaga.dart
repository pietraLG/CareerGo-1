import 'package:flutter/material.dart';
import '../models/vaga.dart';
import '../theme/app_colors.dart';
import 'logo_empresa.dart';

class CartaoVaga extends StatelessWidget {
  final Vaga vaga;
  final bool favorita;
  final VoidCallback onFavoritar;
  final VoidCallback onTap;

  const CartaoVaga({
    super.key,
    required this.vaga,
    required this.favorita,
    required this.onFavoritar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.superficie,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LogoEmpresa(nome: vaga.empresa),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaga.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texto,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vaga.empresa,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textoSuave,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textoSuave),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            vaga.local,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textoSuave,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (vaga.modalidade != null)
                          _Etiqueta(vaga.modalidade!, AppColors.statusEnviada),
                        if (vaga.contrato != null)
                          _Etiqueta(vaga.contrato!, AppColors.statusAprovado),
                        if (vaga.categoria.isNotEmpty)
                          _Etiqueta(vaga.categoria, AppColors.roxo),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vaga.salarioTexto,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavoritar,
                icon: Icon(
                  favorita ? Icons.favorite : Icons.favorite_border,
                  color: favorita ? AppColors.roxo : AppColors.textoSuave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Etiqueta pequena e colorida (Remoto, Full-time, profissão...)
class _Etiqueta extends StatelessWidget {
  final String texto;
  final Color cor;
  const _Etiqueta(this.texto, this.cor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withAlpha(28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: cor,
        ),
      ),
    );
  }
}