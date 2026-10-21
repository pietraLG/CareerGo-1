import 'dart:async';
import 'package:flutter/material.dart';
import '../models/categorias.dart';
import '../models/vaga.dart';
import '../services/adzuna_service.dart';
import '../services/favoritos_service.dart';
import '../theme/app_colors.dart';
import '../widgets/grade_vagas.dart';
import 'vaga_detalhe_screen.dart';

class VagasScreen extends StatefulWidget {
  const VagasScreen({super.key});

  @override
  State<VagasScreen> createState() => _VagasScreenState();
}

class _VagasScreenState extends State<VagasScreen> {
  final _buscaController = TextEditingController();

  List<Vaga> _vagas = [];
  String? _categoria; // null = Todas
  int _pagina = 1;
  bool _carregando = false;
  bool _carregandoMais = false;
  bool _temMais = false;
  String? _erro;
  int _requisicao = 0; // evita que uma resposta antiga sobrescreva a nova

  Set<String> _favoritas = {};
  StreamSubscription<List<Vaga>>? _assinaturaFavoritos;

  @override
  void initState() {
    super.initState();
    _carregar();
    // Escuta os favoritos salvos para pintar os corações
    _assinaturaFavoritos = FavoritosService.observar().listen(
      (lista) {
        if (!mounted) return;
        setState(() => _favoritas = lista.map((v) => v.id).toSet());
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _assinaturaFavoritos?.cancel();
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar({bool reiniciar = true}) async {
    final minha = reiniciar ? ++_requisicao : _requisicao;
    setState(() {
      if (reiniciar) {
        _carregando = true;
        _erro = null;
        _vagas = [];
        _pagina = 1;
      } else {
        _carregandoMais = true;
      }
    });

    try {
      final proxima = reiniciar ? 1 : _pagina + 1;
      final novas = await AdzunaService.buscar(
        busca: _buscaController.text,
        categoria: _categoria,
        pagina: proxima,
      );
      if (!mounted || minha != _requisicao) return;
      setState(() {
        _pagina = proxima;
        _vagas = reiniciar ? novas : [..._vagas, ...novas];
        _temMais = novas.length >= 20;
      });
    } catch (e) {
      if (!mounted || minha != _requisicao) return;
      if (reiniciar) {
        setState(() => _erro = 'Não foi possível carregar as vagas.\n$e');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível carregar mais vagas')),
        );
      }
    } finally {
      if (mounted && minha == _requisicao) {
        setState(() {
          _carregando = false;
          _carregandoMais = false;
        });
      }
    }
  }

  void _escolherCategoria(String? tag) {
    if (tag == _categoria) return;
    _categoria = tag;
    _carregar();
  }

  Future<void> _favoritar(Vaga vaga) async {
    try {
      await FavoritosService.alternar(
        vaga,
        jaFavorita: _favoritas.contains(vaga.id),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Não foi possível salvar o favorito. Confira as regras do Firestore.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Título + sino
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Vagas',
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
                  child: const Icon(Icons.notifications_none_rounded,
                      color: AppColors.texto),
                ),
              ],
            ),
          ),

          // Campo de busca
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _buscaController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _carregar(),
              decoration: const InputDecoration(
                hintText: 'Pesquisar vagas...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Chips: Todas + profissões
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _ChipFiltro(
                  texto: 'Todas',
                  ativo: _categoria == null,
                  onTap: () => _escolherCategoria(null),
                ),
                for (final c in categorias)
                  _ChipFiltro(
                    texto: c.nome,
                    ativo: _categoria == c.tag,
                    onTap: () => _escolherCategoria(c.tag),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(child: _corpo()),
        ],
      ),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textoSuave),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _carregar,
                child: const Text('Tentar de novo'),
              ),
            ],
          ),
        ),
      );
    }

    if (_vagas.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma vaga encontrada',
          style: TextStyle(color: AppColors.textoSuave),
        ),
      );
    }

    return GradeVagas(
      vagas: _vagas,
      favoritas: _favoritas,
      onFavoritar: _favoritar,
      onAbrir: (vaga) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VagaDetalheScreen(
            vaga: vaga,
            jaFavorita: _favoritas.contains(vaga.id),
            onFavoritar: () => _favoritar(vaga),
          ),
        ),
      ),
      rodape: Column(
        children: [
          if (_temMais)
            _carregandoMais
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  )
                : OutlinedButton(
                    onPressed: () => _carregar(reiniciar: false),
                    child: const Text('Carregar mais'),
                  ),
          const SizedBox(height: 12),
          const Text(
            'Jobs by Adzuna',
            style: TextStyle(fontSize: 12, color: AppColors.textoSuave),
          ),
        ],
      ),
    );
  }
}

// Chip de filtro (o ativo tem o degradê roxo-azul)
class _ChipFiltro extends StatelessWidget {
  final String texto;
  final bool ativo;
  final VoidCallback onTap;

  const _ChipFiltro({
    required this.texto,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: ativo ? AppColors.degrade : null,
            color: ativo ? null : AppColors.superficie,
            borderRadius: BorderRadius.circular(20),
            border: ativo ? null : Border.all(color: AppColors.borda),
          ),
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ativo ? Colors.white : AppColors.texto,
            ),
          ),
        ),
      ),
    );
  }
}
