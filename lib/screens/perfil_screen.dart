import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/candidatura.dart';
import '../services/candidaturas_service.dart';
import '../theme/app_colors.dart';
import 'curriculo_screen.dart';
import 'login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  List<Candidatura> _candidaturas = [];
  StreamSubscription<List<Candidatura>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = CandidaturasService.observar().listen(
      (lista) {
        if (mounted) setState(() => _candidaturas = lista);
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _sair() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (r) => false,
    );
  }

  void _editarNome() {
    final ctrl = TextEditingController(
        text: FirebaseAuth.instance.currentUser?.displayName ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar nome'),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: ctrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Seu nome completo'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.currentUser
                  ?.updateDisplayName(ctrl.text.trim());
              if (mounted) setState(() {});
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;
    final nomeCompleto = (usuario?.displayName ?? '').trim();
    final inicial = nomeCompleto.isNotEmpty
        ? nomeCompleto[0].toUpperCase()
        : (usuario?.email?[0].toUpperCase() ?? '?');

    final total = _candidaturas.length;
    final emAnalise =
        _candidaturas.where((c) => c.status == 'analise').length;
    final entrevistas =
        _candidaturas.where((c) => c.status == 'entrevista').length;
    final aprovadas =
        _candidaturas.where((c) => c.status == 'aprovada').length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Avatar grande
            Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: AppColors.degrade,
                shape: BoxShape.circle,
              ),
              child: Text(
                inicial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              nomeCompleto.isEmpty ? 'Sem nome' : nomeCompleto,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texto),
            ),
            const SizedBox(height: 4),
            Text(
              usuario?.email ?? '',
              style: const TextStyle(color: AppColors.textoSuave),
            ),
            TextButton.icon(
              onPressed: _editarNome,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Editar nome'),
            ),
            const SizedBox(height: 24),

            // Card currículo
            _CardAcao(
              icone: Icons.description_rounded,
              titulo: 'Meu Currículo',
              subtitulo: 'Monte e gerencie seu currículo',
              cor: AppColors.roxo,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const CurriculoScreen()),
              ),
            ),
            const SizedBox(height: 12),

            // Card estatísticas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.superficie,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borda),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Minhas candidaturas',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.texto)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Stat('Total', '$total', AppColors.roxo),
                      _Stat('Em análise', '$emAnalise',
                          AppColors.statusAnalise),
                      _Stat('Entrevistas', '$entrevistas',
                          AppColors.statusEntrevista),
                      _Stat('Aprovadas', '$aprovadas',
                          AppColors.statusAprovado),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botão sair
            OutlinedButton.icon(
              onPressed: _sair,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sair da conta'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: AppColors.statusRejeitado,
                side: const BorderSide(color: AppColors.statusRejeitado),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardAcao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final Color cor;
  final VoidCallback onTap;

  const _CardAcao({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.superficie,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: cor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.texto)),
                    Text(subtitulo,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textoSuave)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textoSuave),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String rotulo;
  final String valor;
  final Color cor;

  const _Stat(this.rotulo, this.valor, this.cor);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(valor,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: cor)),
          Text(rotulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textoSuave)),
        ],
      ),
    );
  }
}
