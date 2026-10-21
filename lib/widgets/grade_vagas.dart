import 'package:flutter/material.dart';
import '../models/vaga.dart';
import 'cartao_vaga.dart';

class GradeVagas extends StatelessWidget {
  final List<Vaga> vagas;
  final Set<String> favoritas;
  final void Function(Vaga) onFavoritar;
  final void Function(Vaga) onAbrir;
  final Widget? rodape;

  const GradeVagas({
    super.key,
    required this.vagas,
    required this.favoritas,
    required this.onFavoritar,
    required this.onAbrir,
    this.rodape,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricoes) {
        // Largura disponível decide quantas colunas
        final colunas = restricoes.maxWidth >= 760 ? 2 : 1;
        final linhas = (vagas.length / colunas).ceil();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          itemCount: linhas + 1, // +1 = rodapé
          itemBuilder: (context, indice) {
            if (indice == linhas) return rodape ?? const SizedBox.shrink();

            final itens = <Widget>[];
            for (var i = 0; i < colunas; i++) {
              final posicao = indice * colunas + i;
              if (i > 0) itens.add(const SizedBox(width: 12));
              if (posicao < vagas.length) {
                final vaga = vagas[posicao];
                itens.add(
                  Expanded(
                    child: CartaoVaga(
                      vaga: vaga,
                      favorita: favoritas.contains(vaga.id),
                      onFavoritar: () => onFavoritar(vaga),
                      onTap: () => onAbrir(vaga),
                    ),
                  ),
                );
              } else {
                itens.add(const Expanded(child: SizedBox.shrink()));
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              // IntrinsicHeight deixa os cartões da mesma linha com a mesma altura
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: itens,
                ),
              ),
            );
          },
        );
      },
    );
  }
}