import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'candidaturas_screen.dart';
import 'curriculo_screen.dart';
import 'favoritos_screen.dart';
import 'inicio_screen.dart';
import 'perfil_screen.dart';
import 'vagas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _aba = 0;

  void _irParaAba(int indice) => setState(() => _aba = indice);

  // Índices: 0 Início, 1 Vagas, 2 Candidaturas, 3 Favoritos, 4 Currículo, 5 Perfil
  List<Widget> get _telas => [
        InicioScreen(onIrParaAba: _irParaAba),
        const VagasScreen(),
        const CandidaturasScreen(),
        const FavoritosScreen(),
        const CurriculoScreen(),
        const PerfilScreen(),
      ];

  static const _destinos = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Início',
    ),
    NavigationDestination(
      icon: Icon(Icons.work_outline),
      selectedIcon: Icon(Icons.work_rounded),
      label: 'Vagas',
    ),
    NavigationDestination(
      icon: Icon(Icons.assignment_outlined),
      selectedIcon: Icon(Icons.assignment_rounded),
      label: 'Candidaturas',
    ),
    NavigationDestination(
      icon: Icon(Icons.favorite_border),
      selectedIcon: Icon(Icons.favorite_rounded),
      label: 'Favoritos',
    ),
    NavigationDestination(
      icon: Icon(Icons.description_outlined),
      selectedIcon: Icon(Icons.description_rounded),
      label: 'Currículo',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Perfil',
    ),
  ];

  static const _railDestinos = [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: Text('Início'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.work_outline),
      selectedIcon: Icon(Icons.work_rounded),
      label: Text('Vagas'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.assignment_outlined),
      selectedIcon: Icon(Icons.assignment_rounded),
      label: Text('Candidaturas'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.favorite_border),
      selectedIcon: Icon(Icons.favorite_rounded),
      label: Text('Favoritos'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.description_outlined),
      selectedIcon: Icon(Icons.description_rounded),
      label: Text('Currículo'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person_rounded),
      label: Text('Perfil'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;

    // ── Desktop / tablet largo (≥ 900px): Rail lateral + conteúdo centralizado ──
    if (largura >= 900) {
      return Scaffold(
        backgroundColor: AppColors.fundo,
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: AppColors.superficie,
              selectedIndex: _aba,
              onDestinationSelected: _irParaAba,
              labelType: NavigationRailLabelType.all,
              selectedIconTheme:
                  const IconThemeData(color: AppColors.roxo),
              selectedLabelTextStyle:
                  const TextStyle(color: AppColors.roxo, fontWeight: FontWeight.w600),
              unselectedIconTheme:
                  const IconThemeData(color: AppColors.textoSuave),
              destinations: _railDestinos,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: IndexedStack(index: _aba, children: _telas),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Tablet médio (600–900px): Rail compacto (só ícones) ──
    if (largura >= 600) {
      return Scaffold(
        backgroundColor: AppColors.fundo,
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: AppColors.superficie,
              selectedIndex: _aba,
              onDestinationSelected: _irParaAba,
              labelType: NavigationRailLabelType.none,
              selectedIconTheme:
                  const IconThemeData(color: AppColors.roxo),
              unselectedIconTheme:
                  const IconThemeData(color: AppColors.textoSuave),
              destinations: _railDestinos,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: IndexedStack(index: _aba, children: _telas),
            ),
          ],
        ),
      );
    }

    // ── Celular (< 600px): NavigationBar embaixo ──
    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: IndexedStack(index: _aba, children: _telas),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.superficie,
          indicatorColor: Colors.transparent,
          iconTheme: WidgetStateProperty.resolveWith((estados) {
            final ativo = estados.contains(WidgetState.selected);
            return IconThemeData(
              color: ativo ? AppColors.roxo : AppColors.textoSuave,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((estados) {
            final ativo = estados.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 10,
              fontWeight: ativo ? FontWeight.w600 : FontWeight.normal,
              color: ativo ? AppColors.roxo : AppColors.textoSuave,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _aba,
          onDestinationSelected: _irParaAba,
          destinations: _destinos,
        ),
      ),
    );
  }
}
