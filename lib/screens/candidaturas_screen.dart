import 'dart:async';
import 'package:flutter/material.dart';
import '../models/candidatura.dart';
import '../services/candidaturas_service.dart';
import '../theme/app_colors.dart';

class CandidaturasScreen extends StatefulWidget {
  const CandidaturasScreen({super.key});

  @override
  State<CandidaturasScreen> createState() => _CandidaturasScreenState();
}

class _CandidaturasScreenState extends State<CandidaturasScreen> {
  List<Candidatura> _lista = [];
  StreamSubscription<List<Candidatura>>? _sub;

  static const _statusLabels = [
    'enviada',
    'analise',
    'entrevista',
    'teste',
    'aprovada',
    'rejeitada',
  ];

  static const _statusNomes = {
    'enviada': 'Enviada',
    'analise': 'Em análise',
    'entrevista': 'Entrevista',
    'teste': 'Teste técnico',
    'aprovada': 'Aprovada',
    'rejeitada': 'Rejeitada',
  };

  static const _statusCores = {
    'enviada': AppColors.statusEnviada,
    'analise': AppColors.statusAnalise,
    'entrevista': AppColors.statusEntrevista,
    'teste': AppColors.statusTeste,
    'aprovada': AppColors.statusAprovado,
    'rejeitada': AppColors.statusRejeitado,
  };

  @override
  void initState() {
    super.initState();
    _sub = CandidaturasService.observar().listen(
      (lista) {
        if (mounted) setState(() => _lista = lista);
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _remover(Candidatura c) async {
    await CandidaturasService.remover(c.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Candidatura "${c.vagaTitulo}" removida'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => CandidaturasService.adicionar(c),
          ),
        ),
      );
    }
  }

  void _editarStatus(Candidatura c) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _StatusSheet(
        statusAtual: c.status,
        onEscolher: (novoStatus) async {
          Navigator.pop(context);
          await CandidaturasService.atualizarStatus(c.id, novoStatus);
        },
        statusLabels: _statusLabels,
        statusNomes: _statusNomes,
        statusCores: _statusCores,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Candidaturas',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texto,
                    ),
                  ),
                ),
                Text(
                  '${_lista.length}',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.roxo),
                ),
              ],
            ),
          ),
          Expanded(
            child: _lista.isEmpty
                ? _EstadoVazio()
                : largura >= 700
                    ? _GridCandidaturas(
                        lista: _lista,
                        statusNomes: _statusNomes,
                        statusCores: _statusCores,
                        onEditar: _editarStatus,
                        onRemover: _remover,
                      )
                    : _ListaCandidaturas(
                        lista: _lista,
                        statusNomes: _statusNomes,
                        statusCores: _statusCores,
                        onEditar: _editarStatus,
                        onRemover: _remover,
                      ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Lista (celular)
// ──────────────────────────────────────────────
class _ListaCandidaturas extends StatelessWidget {
  final List<Candidatura> lista;
  final Map<String, String> statusNomes;
  final Map<String, Color> statusCores;
  final void Function(Candidatura) onEditar;
  final void Function(Candidatura) onRemover;

  const _ListaCandidaturas({
    required this.lista,
    required this.statusNomes,
    required this.statusCores,
    required this.onEditar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: lista.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _CartaoCandidatura(
        candidatura: lista[i],
        statusNomes: statusNomes,
        statusCores: statusCores,
        onEditar: onEditar,
        onRemover: onRemover,
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Grid (tablet / desktop)
// ──────────────────────────────────────────────
class _GridCandidaturas extends StatelessWidget {
  final List<Candidatura> lista;
  final Map<String, String> statusNomes;
  final Map<String, Color> statusCores;
  final void Function(Candidatura) onEditar;
  final void Function(Candidatura) onRemover;

  const _GridCandidaturas({
    required this.lista,
    required this.statusNomes,
    required this.statusCores,
    required this.onEditar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: lista.length,
      itemBuilder: (_, i) => _CartaoCandidatura(
        candidatura: lista[i],
        statusNomes: statusNomes,
        statusCores: statusCores,
        onEditar: onEditar,
        onRemover: onRemover,
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Cartão individual
// ──────────────────────────────────────────────
class _CartaoCandidatura extends StatelessWidget {
  final Candidatura candidatura;
  final Map<String, String> statusNomes;
  final Map<String, Color> statusCores;
  final void Function(Candidatura) onEditar;
  final void Function(Candidatura) onRemover;

  const _CartaoCandidatura({
    required this.candidatura,
    required this.statusNomes,
    required this.statusCores,
    required this.onEditar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final cor = statusCores[candidatura.status] ?? AppColors.textoSuave;
    final nome = statusNomes[candidatura.status] ?? candidatura.status;
    final data = _formatarData(candidatura.dataEnvio);

    return Dismissible(
      key: Key(candidatura.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.statusRejeitado,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Remover candidatura?'),
            content: Text(
                'Deseja remover a candidatura para "${candidatura.vagaTitulo}"?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Remover',
                      style: TextStyle(color: AppColors.statusRejeitado))),
            ],
          ),
        );
      },
      onDismissed: (_) => onRemover(candidatura),
      child: Material(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onEditar(candidatura),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        candidatura.vagaTitulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.texto,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: cor.withAlpha(28),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(nome,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cor)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(candidatura.vagaEmpresa,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textoSuave, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.textoSuave),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(candidatura.vagaLocal,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textoSuave)),
                    ),
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: AppColors.textoSuave),
                    const SizedBox(width: 4),
                    Text(data,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textoSuave)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Toque para alterar status · Arraste para remover',
                  style: TextStyle(fontSize: 11, color: AppColors.borda),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ──────────────────────────────────────────────
// Bottom sheet de seleção de status
// ──────────────────────────────────────────────
class _StatusSheet extends StatelessWidget {
  final String statusAtual;
  final void Function(String) onEscolher;
  final List<String> statusLabels;
  final Map<String, String> statusNomes;
  final Map<String, Color> statusCores;

  const _StatusSheet({
    required this.statusAtual,
    required this.onEscolher,
    required this.statusLabels,
    required this.statusNomes,
    required this.statusCores,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Atualizar status',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texto)),
          const SizedBox(height: 16),
          ...statusLabels.map((s) {
            final cor = statusCores[s] ?? AppColors.textoSuave;
            final nome = statusNomes[s] ?? s;
            final ativo = s == statusAtual;
            return ListTile(
              onTap: () => onEscolher(s),
              leading: Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(color: cor, shape: BoxShape.circle),
              ),
              title: Text(nome,
                  style: TextStyle(
                      fontWeight:
                          ativo ? FontWeight.bold : FontWeight.normal)),
              trailing: ativo
                  ? Icon(Icons.check_rounded, color: cor)
                  : null,
            );
          }),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Estado vazio
// ──────────────────────────────────────────────
class _EstadoVazio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.assignment_outlined,
                size: 56, color: AppColors.borda),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma candidatura ainda',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texto),
            ),
            const SizedBox(height: 6),
            const Text(
              'Candidate-se a vagas na aba Vagas\ne elas aparecem aqui automaticamente.',
              style: TextStyle(color: AppColors.textoSuave),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
