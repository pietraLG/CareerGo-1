import 'dart:async';
import 'package:flutter/material.dart';
import '../models/vaga.dart';
import '../services/favoritos_service.dart';
import '../theme/app_colors.dart';
import '../widgets/grade_vagas.dart';
import 'vaga_detalhe_screen.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  List<Vaga> _favoritos = [];
  StreamSubscription<List<Vaga>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FavoritosService.observar().listen(
      (lista) {
        if (mounted) setState(() => _favoritos = lista);
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _alternar(Vaga vaga) async {
    try {
      await FavoritosService.alternar(
        vaga,
        jaFavorita: _favoritos.any((v) => v.id == vaga.id),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível alterar o favorito.')),
      );
    }
  }

  void _abrirDetalhe(Vaga vaga) {
    final jaFav = _favoritos.any((v) => v.id == vaga.id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VagaDetalheScreen(
          vaga: vaga,
          jaFavorita: jaFav,
          onFavoritar: () => _alternar(vaga),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Cabeçalho
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Favoritos',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texto,
                    ),
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.superficie,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: AppColors.roxo),
                ),
              ],
            ),
          ),
          Expanded(
            child: _favoritos.isEmpty
                ? _EstadoVazio()
                : GradeVagas(
                    vagas: _favoritos,
                    favoritas: _favoritos.map((v) => v.id).toSet(),
                    onFavoritar: _alternar,
                    onAbrir: _abrirDetalhe,
                  ),
          ),
        ],
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border_rounded,
              size: 56, color: AppColors.borda),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma vaga favoritada ainda',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.texto),
          ),
          const SizedBox(height: 6),
          const Text(
            'Toque no ❤️ em qualquer vaga para salvar aqui.',
            style: TextStyle(color: AppColors.textoSuave),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
