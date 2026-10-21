import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/candidatura.dart';
import '../services/candidaturas_service.dart';
import '../theme/app_colors.dart';

class InicioScreen extends StatelessWidget {
  // Função chamada quando o usuário toca num atalho. Recebe o número da aba.
  final void Function(int aba) onIrParaAba;

  const InicioScreen({super.key, required this.onIrParaAba});

  @override
  Widget build(BuildContext context) {
    // Pega o nome que foi salvo no cadastro
    final usuario = FirebaseAuth.instance.currentUser;
    final nomeCompleto = (usuario?.displayName ?? '').trim();
    String primeiroNome = 'você';
    String inicial = '?';
    if (nomeCompleto.isNotEmpty) {
      final p = nomeCompleto.split(' ').first;
      primeiroNome = p[0].toUpperCase() + p.substring(1);
      inicial = p[0].toUpperCase();
    } else if (usuario?.email != null && usuario!.email!.isNotEmpty) {
      inicial = usuario.email![0].toUpperCase();
    }

    return SafeArea(
      child: StreamBuilder<List<Candidatura>>(
        stream: CandidaturasService.observar(),
        builder: (context, snapshot) {
          final candidaturas = snapshot.data ?? [];
          final totalCandidaturas = candidaturas.length;
          final emAnalise =
              candidaturas.where((c) => c.status == 'analise').length;
          final entrevistas =
              candidaturas.where((c) => c.status == 'entrevista').length;
          final aprovadas =
              candidaturas.where((c) => c.status == 'aprovada').length;
          final rejeitadas =
              candidaturas.where((c) => c.status == 'rejeitada').length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saudação + avatar
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Olá, $primeiroNome! 👋',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.texto,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Vamos encontrar sua próxima oportunidade?',
                            style: TextStyle(color: AppColors.textoSuave),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => onIrParaAba(5), // Ir para perfil
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          gradient: AppColors.degrade,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          inicial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Cartão com o resumo das candidaturas
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.superficie,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _CartaoResumo(
                              icone: Icons.shield_outlined,
                              numero: totalCandidaturas,
                              rotulo: 'Candidaturas',
                              cor: AppColors.roxo,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _CartaoResumo(
                              icone: Icons.hourglass_empty_rounded,
                              numero: emAnalise,
                              rotulo: 'Em análise',
                              cor: AppColors.statusAnalise,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _CartaoResumo(
                              icone: Icons.groups_outlined,
                              numero: entrevistas,
                              rotulo: 'Entrevistas',
                              cor: AppColors.statusEnviada,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _CartaoResumo(
                              icone: Icons.check_circle_outline,
                              numero: aprovadas,
                              rotulo: 'Aprovada',
                              cor: AppColors.statusAprovado,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _CartaoResumo(
                              icone: Icons.cancel_outlined,
                              numero: rejeitadas,
                              rotulo: 'Rejeitada',
                              cor: AppColors.statusRejeitado,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Banner Criar/Editar Currículo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B4DFF), Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x337B4DFF),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.description_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Crie seu Currículo 📄',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Monte seu currículo completo para conquistar vagas.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => onIrParaAba(4), // Aba de Currículo
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.roxo,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Montar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Acesso rápido
                const Text(
                  'Acesso rápido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.texto,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CartaoAtalho(
                        icone: Icons.search,
                        rotulo: 'Vagas',
                        cor: AppColors.statusEnviada,
                        onTap: () => onIrParaAba(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CartaoAtalho(
                        icone: Icons.favorite_border,
                        rotulo: 'Favoritos',
                        cor: AppColors.statusRejeitado,
                        onTap: () => onIrParaAba(3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CartaoAtalho(
                        icone: Icons.assignment_outlined,
                        rotulo: 'Candidaturas',
                        cor: AppColors.roxo,
                        onTap: () => onIrParaAba(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CartaoAtalho(
                        icone: Icons.description_outlined,
                        rotulo: 'Meu Currículo',
                        cor: AppColors.statusAnalise,
                        onTap: () => onIrParaAba(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Cartãozinho colorido com ícone, número e nome (parte do resumo)
class _CartaoResumo extends StatelessWidget {
  final IconData icone;
  final int numero;
  final String rotulo;
  final Color cor;

  const _CartaoResumo({
    required this.icone,
    required this.numero,
    required this.rotulo,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withAlpha(30), // a cor do ícone, bem clarinha, no fundo
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 18, color: cor),
              const SizedBox(width: 6),
              Text(
                '$numero',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            rotulo,
            style: const TextStyle(fontSize: 12, color: AppColors.textoSuave),
          ),
        ],
      ),
    );
  }
}

// Cartão branco do "Acesso rápido"
class _CartaoAtalho extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final Color cor;
  final VoidCallback onTap;

  const _CartaoAtalho({
    required this.icone,
    required this.rotulo,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borda),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: cor),
              ),
              const SizedBox(height: 10),
              Text(
                rotulo,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.texto,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
