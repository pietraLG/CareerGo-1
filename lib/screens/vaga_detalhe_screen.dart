import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/candidatura.dart';
import '../models/vaga.dart';
import '../services/candidaturas_service.dart';
import '../theme/app_colors.dart';
import '../widgets/logo_empresa.dart';

class VagaDetalheScreen extends StatefulWidget {
  final Vaga vaga;
  final bool jaFavorita;
  final VoidCallback onFavoritar;

  const VagaDetalheScreen({
    super.key,
    required this.vaga,
    required this.jaFavorita,
    required this.onFavoritar,
  });

  @override
  State<VagaDetalheScreen> createState() => _VagaDetalheScreenState();
}

class _VagaDetalheScreenState extends State<VagaDetalheScreen> {
  late bool _favorita;
  bool _candidatando = false;

  @override
  void initState() {
    super.initState();
    _favorita = widget.jaFavorita;
  }

  Future<void> _abrirLink() async {
    final uri = Uri.tryParse(widget.vaga.link);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _candidatar() async {
    setState(() => _candidatando = true);
    try {
      await _abrirLink();
      if (!mounted) return;
      final confirmou = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Candidatura enviada?'),
          content: const Text(
              'Deseja registrar essa candidatura para acompanhar o status?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Não')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Sim, registrar')),
          ],
        ),
      );
      if (confirmou == true && mounted) {
        final candidatura = Candidatura(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          vagaId: widget.vaga.id,
          vagaTitulo: widget.vaga.titulo,
          vagaEmpresa: widget.vaga.empresa,
          vagaLink: widget.vaga.link,
          vagaLocal: widget.vaga.local,
          dataEnvio: DateTime.now(),
        );
        await CandidaturasService.adicionar(candidatura);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Candidatura registrada! ✅')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _candidatando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;
    final conteudo = _Conteudo(
      vaga: widget.vaga,
      favorita: _favorita,
      candidatando: _candidatando,
      onFavoritar: () {
        setState(() => _favorita = !_favorita);
        widget.onFavoritar();
      },
      onVerLink: _abrirLink,
      onCandidatar: _candidatar,
    );

    // Em telas largas mostra como Dialog centralizado
    if (largura >= 700) {
      return Dialog(
        insetPadding: const EdgeInsets.all(32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: conteudo,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: conteudo,
    );
  }
}

class _Conteudo extends StatelessWidget {
  final Vaga vaga;
  final bool favorita;
  final bool candidatando;
  final VoidCallback onFavoritar;
  final VoidCallback onVerLink;
  final VoidCallback onCandidatar;

  const _Conteudo({
    required this.vaga,
    required this.favorita,
    required this.candidatando,
    required this.onFavoritar,
    required this.onVerLink,
    required this.onCandidatar,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          // AppBar interno
          Container(
            color: AppColors.superficie,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Detalhe da Vaga',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.texto),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        favorita ? Icons.favorite : Icons.favorite_border,
                        color: favorita ? AppColors.roxo : AppColors.textoSuave,
                      ),
                      onPressed: onFavoritar,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          // Corpo com scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LogoEmpresa(nome: vaga.empresa, tamanho: 56),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vaga.titulo,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.texto)),
                            const SizedBox(height: 4),
                            Text(vaga.empresa,
                                style: const TextStyle(
                                    color: AppColors.textoSuave)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(Icons.location_on_outlined, vaga.local),
                  if (vaga.contrato != null)
                    _InfoRow(Icons.work_outline, vaga.contrato!),
                  if (vaga.modalidade != null)
                    _InfoRow(Icons.home_work_outlined, vaga.modalidade!),
                  _InfoRow(Icons.attach_money_rounded, vaga.salarioTexto,
                      cor: const Color(0xFF16A34A)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (vaga.modalidade != null)
                        _Chip(vaga.modalidade!, AppColors.statusEnviada),
                      if (vaga.contrato != null)
                        _Chip(vaga.contrato!, AppColors.statusAprovado),
                      if (vaga.categoria.isNotEmpty)
                        _Chip(vaga.categoria, AppColors.roxo),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Descrição',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.texto)),
                  const SizedBox(height: 8),
                  Text(
                    vaga.descricao.isEmpty
                        ? 'Sem descrição disponível.'
                        : vaga.descricao,
                    style: const TextStyle(
                        color: AppColors.textoSuave, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  // Botões de ação
                  OutlinedButton.icon(
                    onPressed: onVerLink,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Ver vaga completa'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: AppColors.roxo,
                      side: const BorderSide(color: AppColors.roxo),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _BotaoDegradeFull(
                    texto:
                        candidatando ? 'Abrindo...' : 'Candidatar-me 🚀',
                    onPressed: candidatando ? null : onCandidatar,
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text('Jobs by Adzuna',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textoSuave)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icone;
  final String texto;
  final Color? cor;

  const _InfoRow(this.icone, this.texto, {this.cor});

  @override
  Widget build(BuildContext context) {
    final c = cor ?? AppColors.textoSuave;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icone, size: 16, color: c),
          const SizedBox(width: 6),
          Expanded(
              child: Text(texto,
                  style: TextStyle(color: c, fontSize: 13))),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String texto;
  final Color cor;
  const _Chip(this.texto, this.cor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: cor.withAlpha(28),
          borderRadius: BorderRadius.circular(8)),
      child: Text(texto,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: cor)),
    );
  }
}

class _BotaoDegradeFull extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  const _BotaoDegradeFull({required this.texto, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: onPressed != null ? AppColors.degrade : null,
        color: onPressed == null ? AppColors.borda : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Center(
            child: Text(texto,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
