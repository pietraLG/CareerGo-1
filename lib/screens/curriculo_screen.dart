import 'package:flutter/material.dart';
import '../models/curriculo.dart';
import '../services/curriculo_service.dart';
import '../theme/app_colors.dart';
import '../widgets/botao_degrade.dart';

class CurriculoScreen extends StatefulWidget {
  const CurriculoScreen({super.key});

  @override
  State<CurriculoScreen> createState() => _CurriculoScreenState();
}

class _CurriculoScreenState extends State<CurriculoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _carregando = true;
  bool _modoVisualizacao = false;

  // Dados editáveis
  late TextEditingController _objCtrl;
  late TextEditingController _telCtrl;
  late TextEditingController _cidCtrl;
  late TextEditingController _liCtrl;
  late TextEditingController _ghCtrl;

  List<Experiencia> _exps = [];
  List<Formacao> _forms = [];
  List<String> _habs = [];
  List<Idioma> _idiomas = [];

  final _habCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _objCtrl = TextEditingController();
    _telCtrl = TextEditingController();
    _cidCtrl = TextEditingController();
    _liCtrl = TextEditingController();
    _ghCtrl = TextEditingController();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final c = await CurriculoService.carregar();
    if (!mounted) return;
    if (c != null) {
      _objCtrl.text = c.objetivo;
      _telCtrl.text = c.telefone;
      _cidCtrl.text = c.cidade;
      _liCtrl.text = c.linkedin;
      _ghCtrl.text = c.github;
      setState(() {
        _exps = List.from(c.experiencias);
        _forms = List.from(c.formacoes);
        _habs = List.from(c.habilidades);
        _idiomas = List.from(c.idiomas);
      });
    }
    setState(() => _carregando = false);
  }

  Curriculo _montar() => Curriculo(
        objetivo: _objCtrl.text.trim(),
        telefone: _telCtrl.text.trim(),
        linkedin: _liCtrl.text.trim(),
        github: _ghCtrl.text.trim(),
        cidade: _cidCtrl.text.trim(),
        experiencias: _exps,
        formacoes: _forms,
        habilidades: _habs,
        idiomas: _idiomas,
      );

  Future<void> _salvar() async {
    await CurriculoService.salvar(_montar());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Currículo salvo! ✅')),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    _objCtrl.dispose();
    _telCtrl.dispose();
    _cidCtrl.dispose();
    _liCtrl.dispose();
    _ghCtrl.dispose();
    _habCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Meu Currículo',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
                _modoVisualizacao ? Icons.edit_outlined : Icons.preview_rounded),
            tooltip: _modoVisualizacao ? 'Editar' : 'Visualizar',
            onPressed: () =>
                setState(() => _modoVisualizacao = !_modoVisualizacao),
          ),
        ],
        bottom: _modoVisualizacao
            ? null
            : TabBar(
                controller: _tabs,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.roxo,
                indicatorColor: AppColors.roxo,
                tabs: const [
                  Tab(text: 'Sobre você'),
                  Tab(text: 'Experiências'),
                  Tab(text: 'Formação'),
                  Tab(text: 'Habilidades'),
                ],
              ),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _modoVisualizacao
              ? _Visualizacao(curriculo: _montar())
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _StepSobreVoce(
                      objCtrl: _objCtrl,
                      telCtrl: _telCtrl,
                      cidCtrl: _cidCtrl,
                      liCtrl: _liCtrl,
                      ghCtrl: _ghCtrl,
                      onSalvar: _salvar,
                    ),
                    _StepExperiencias(
                      lista: _exps,
                      onAtualizar: (l) => setState(() => _exps = l),
                      onSalvar: _salvar,
                    ),
                    _StepFormacao(
                      lista: _forms,
                      onAtualizar: (l) => setState(() => _forms = l),
                      onSalvar: _salvar,
                    ),
                    _StepHabilidades(
                      habs: _habs,
                      idiomas: _idiomas,
                      habCtrl: _habCtrl,
                      onAtualizarHabs: (l) => setState(() => _habs = l),
                      onAtualizarIdiomas: (l) => setState(() => _idiomas = l),
                      onSalvar: _salvar,
                    ),
                  ],
                ),
    );
  }
}

// ──────────────── STEP 1: Sobre você ────────────────
class _StepSobreVoce extends StatelessWidget {
  final TextEditingController objCtrl, telCtrl, cidCtrl, liCtrl, ghCtrl;
  final VoidCallback onSalvar;

  const _StepSobreVoce({
    required this.objCtrl,
    required this.telCtrl,
    required this.cidCtrl,
    required this.liCtrl,
    required this.ghCtrl,
    required this.onSalvar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('Objetivo profissional'),
          TextField(
            controller: objCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
                hintText:
                    'Ex: Desenvolvedor Flutter com 2 anos de experiência...'),
          ),
          const SizedBox(height: 16),
          _Label('Telefone / WhatsApp'),
          TextField(
              controller: telCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '(11) 99999-9999')),
          const SizedBox(height: 16),
          _Label('Cidade'),
          TextField(
              controller: cidCtrl,
              decoration:
                  const InputDecoration(hintText: 'Ex: São Paulo, SP')),
          const SizedBox(height: 16),
          _Label('LinkedIn (URL)'),
          TextField(
              controller: liCtrl,
              decoration: const InputDecoration(
                  hintText: 'linkedin.com/in/seuperfil')),
          const SizedBox(height: 16),
          _Label('GitHub (URL)'),
          TextField(
              controller: ghCtrl,
              decoration:
                  const InputDecoration(hintText: 'github.com/seuusuario')),
          const SizedBox(height: 24),
          BotaoDegrade(texto: 'Salvar', onPressed: onSalvar),
        ],
      ),
    );
  }
}

// ──────────────── STEP 2: Experiências ────────────────
class _StepExperiencias extends StatelessWidget {
  final List<Experiencia> lista;
  final void Function(List<Experiencia>) onAtualizar;
  final VoidCallback onSalvar;

  const _StepExperiencias(
      {required this.lista,
      required this.onAtualizar,
      required this.onSalvar});

  void _adicionar(BuildContext ctx) async {
    final result = await _dialogExp(ctx, null);
    if (result != null) onAtualizar([...lista, result]);
  }

  void _editar(BuildContext ctx, int i) async {
    final result = await _dialogExp(ctx, lista[i]);
    if (result != null) {
      final nova = List<Experiencia>.from(lista);
      nova[i] = result;
      onAtualizar(nova);
    }
  }

  void _remover(int i) {
    final nova = List<Experiencia>.from(lista)..removeAt(i);
    onAtualizar(nova);
  }

  Future<Experiencia?> _dialogExp(BuildContext ctx, Experiencia? atual) {
    final cargo = TextEditingController(text: atual?.cargo ?? '');
    final emp = TextEditingController(text: atual?.empresa ?? '');
    final per = TextEditingController(text: atual?.periodo ?? '');
    final desc = TextEditingController(text: atual?.descricao ?? '');
    return showDialog<Experiencia>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text(atual == null ? 'Nova experiência' : 'Editar experiência'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: cargo,
                  decoration: const InputDecoration(hintText: 'Cargo')),
              const SizedBox(height: 12),
              TextField(
                  controller: emp,
                  decoration: const InputDecoration(hintText: 'Empresa')),
              const SizedBox(height: 12),
              TextField(
                  controller: per,
                  decoration: const InputDecoration(
                      hintText: 'Período (ex: Jan/2022 – Atual)')),
              const SizedBox(height: 12),
              TextField(
                  controller: desc,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      hintText: 'Descrição das atividades')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(
                  c,
                  Experiencia(
                    cargo: cargo.text.trim(),
                    empresa: emp.text.trim(),
                    periodo: per.text.trim(),
                    descricao: desc.text.trim(),
                  )),
              child: const Text('Salvar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: lista.isEmpty
              ? const Center(
                  child: Text('Nenhuma experiência adicionada.',
                      style: TextStyle(color: AppColors.textoSuave)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _CardItem(
                    titulo: lista[i].cargo,
                    subtitulo: lista[i].empresa,
                    info: lista[i].periodo,
                    onEditar: () => _editar(context, i),
                    onRemover: () => _remover(i),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              OutlinedButton.icon(
                onPressed: () => _adicionar(context),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar experiência'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: AppColors.roxo,
                  side: const BorderSide(color: AppColors.roxo),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              BotaoDegrade(texto: 'Salvar', onPressed: onSalvar),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────── STEP 3: Formação ────────────────
class _StepFormacao extends StatelessWidget {
  final List<Formacao> lista;
  final void Function(List<Formacao>) onAtualizar;
  final VoidCallback onSalvar;

  const _StepFormacao(
      {required this.lista,
      required this.onAtualizar,
      required this.onSalvar});

  void _adicionar(BuildContext ctx) async {
    final result = await _dialog(ctx, null);
    if (result != null) onAtualizar([...lista, result]);
  }

  void _remover(int i) {
    final nova = List<Formacao>.from(lista)..removeAt(i);
    onAtualizar(nova);
  }

  Future<Formacao?> _dialog(BuildContext ctx, Formacao? atual) {
    final curso = TextEditingController(text: atual?.curso ?? '');
    final inst = TextEditingController(text: atual?.instituicao ?? '');
    final per = TextEditingController(text: atual?.periodo ?? '');
    return showDialog<Formacao>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Formação acadêmica'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: curso,
                decoration: const InputDecoration(
                    hintText: 'Curso (ex: Análise de Sistemas)')),
            const SizedBox(height: 12),
            TextField(
                controller: inst,
                decoration:
                    const InputDecoration(hintText: 'Instituição')),
            const SizedBox(height: 12),
            TextField(
                controller: per,
                decoration: const InputDecoration(
                    hintText: 'Período (ex: 2020 – 2023)')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(
                  c,
                  Formacao(
                    curso: curso.text.trim(),
                    instituicao: inst.text.trim(),
                    periodo: per.text.trim(),
                  )),
              child: const Text('Salvar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: lista.isEmpty
              ? const Center(
                  child: Text('Nenhuma formação adicionada.',
                      style: TextStyle(color: AppColors.textoSuave)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _CardItem(
                    titulo: lista[i].curso,
                    subtitulo: lista[i].instituicao,
                    info: lista[i].periodo,
                    onEditar: null,
                    onRemover: () => _remover(i),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              OutlinedButton.icon(
                onPressed: () => _adicionar(context),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar formação'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: AppColors.roxo,
                  side: const BorderSide(color: AppColors.roxo),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              BotaoDegrade(texto: 'Salvar', onPressed: onSalvar),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────── STEP 4: Habilidades & Idiomas ────────────────
class _StepHabilidades extends StatelessWidget {
  final List<String> habs;
  final List<Idioma> idiomas;
  final TextEditingController habCtrl;
  final void Function(List<String>) onAtualizarHabs;
  final void Function(List<Idioma>) onAtualizarIdiomas;
  final VoidCallback onSalvar;

  static const _niveis = ['Básico', 'Intermediário', 'Avançado', 'Fluente'];

  const _StepHabilidades({
    required this.habs,
    required this.idiomas,
    required this.habCtrl,
    required this.onAtualizarHabs,
    required this.onAtualizarIdiomas,
    required this.onSalvar,
  });

  void _addHab() {
    final v = habCtrl.text.trim();
    if (v.isEmpty || habs.contains(v)) return;
    onAtualizarHabs([...habs, v]);
    habCtrl.clear();
  }

  void _removeHab(String h) => onAtualizarHabs(habs.where((x) => x != h).toList());

  void _addIdioma(BuildContext ctx) async {
    final result = await _dialogIdioma(ctx, null);
    if (result != null) onAtualizarIdiomas([...idiomas, result]);
  }

  void _removeIdioma(int i) {
    final nova = List<Idioma>.from(idiomas)..removeAt(i);
    onAtualizarIdiomas(nova);
  }

  Future<Idioma?> _dialogIdioma(BuildContext ctx, Idioma? atual) {
    final nomeCtrl = TextEditingController(text: atual?.nome ?? '');
    String nivel = atual?.nivel ?? 'Básico';
    return showDialog<Idioma>(
      context: ctx,
      builder: (c) => StatefulBuilder(
        builder: (c2, setSt) => AlertDialog(
          title: const Text('Idioma'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nomeCtrl,
                  decoration:
                      const InputDecoration(hintText: 'Ex: Inglês, Espanhol')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: nivel,
                decoration:
                    const InputDecoration(labelText: 'Nível'),
                items: _niveis
                    .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                    .toList(),
                onChanged: (v) => setSt(() => nivel = v ?? nivel),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () => Navigator.pop(
                    c, Idioma(nome: nomeCtrl.text.trim(), nivel: nivel)),
                child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('Habilidades técnicas'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: habCtrl,
                  decoration: const InputDecoration(
                      hintText: 'Ex: Flutter, Python, SQL...'),
                  onSubmitted: (_) => _addHab(),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _addHab,
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: habs
                .map((h) => Chip(
                      label: Text(h),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _removeHab(h),
                      backgroundColor: AppColors.roxo.withAlpha(20),
                      labelStyle: const TextStyle(color: AppColors.roxo),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          _Label('Idiomas'),
          ...idiomas.asMap().entries.map(
                (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.language_rounded,
                      color: AppColors.roxo),
                  title: Text(e.value.nome),
                  subtitle: Text(e.value.nivel),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.statusRejeitado),
                    onPressed: () => _removeIdioma(e.key),
                  ),
                ),
              ),
          OutlinedButton.icon(
            onPressed: () => _addIdioma(context),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar idioma'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.roxo,
              side: const BorderSide(color: AppColors.roxo),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 24),
          BotaoDegrade(texto: 'Salvar tudo', onPressed: onSalvar),
        ],
      ),
    );
  }
}

// ──────────────── Modo Visualização ────────────────
class _Visualizacao extends StatelessWidget {
  final Curriculo curriculo;
  const _Visualizacao({required this.curriculo});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (curriculo.objetivo.isNotEmpty) ...[
            _SecTitulo('Objetivo'),
            Text(curriculo.objetivo,
                style: const TextStyle(color: AppColors.textoSuave,height: 1.5)),
            const Divider(height: 32),
          ],
          if (curriculo.telefone.isNotEmpty ||
              curriculo.cidade.isNotEmpty ||
              curriculo.linkedin.isNotEmpty ||
              curriculo.github.isNotEmpty) ...[
            _SecTitulo('Contato'),
            if (curriculo.telefone.isNotEmpty)
              _InfoLinha(Icons.phone_outlined, curriculo.telefone),
            if (curriculo.cidade.isNotEmpty)
              _InfoLinha(Icons.location_on_outlined, curriculo.cidade),
            if (curriculo.linkedin.isNotEmpty)
              _InfoLinha(Icons.link_rounded, curriculo.linkedin),
            if (curriculo.github.isNotEmpty)
              _InfoLinha(Icons.code_rounded, curriculo.github),
            const Divider(height: 32),
          ],
          if (curriculo.experiencias.isNotEmpty) ...[
            _SecTitulo('Experiências'),
            ...curriculo.experiencias.map((e) => _ExpItem(e)),
            const Divider(height: 32),
          ],
          if (curriculo.formacoes.isNotEmpty) ...[
            _SecTitulo('Formação Acadêmica'),
            ...curriculo.formacoes.map((f) => _FormItem(f)),
            const Divider(height: 32),
          ],
          if (curriculo.habilidades.isNotEmpty) ...[
            _SecTitulo('Habilidades'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: curriculo.habilidades
                  .map((h) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.roxo.withAlpha(20),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(h,
                            style: const TextStyle(
                                color: AppColors.roxo,
                                fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
            const Divider(height: 32),
          ],
          if (curriculo.idiomas.isNotEmpty) ...[
            _SecTitulo('Idiomas'),
            ...curriculo.idiomas.map(
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded,
                        size: 16, color: AppColors.roxo),
                    const SizedBox(width: 8),
                    Text(i.nome,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.texto)),
                    const SizedBox(width: 8),
                    Text('· ${i.nivel}',
                        style: const TextStyle(color: AppColors.textoSuave)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SecTitulo extends StatelessWidget {
  final String texto;
  const _SecTitulo(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(texto,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.roxo)),
      );
}

class _InfoLinha extends StatelessWidget {
  final IconData icone;
  final String texto;
  const _InfoLinha(this.icone, this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          Icon(icone, size: 15, color: AppColors.textoSuave),
          const SizedBox(width: 8),
          Expanded(
              child: Text(texto,
                  style: const TextStyle(color: AppColors.textoSuave))),
        ]),
      );
}

class _ExpItem extends StatelessWidget {
  final Experiencia exp;
  const _ExpItem(this.exp);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(exp.cargo,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.texto)),
          Text('${exp.empresa} · ${exp.periodo}',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textoSuave)),
          if (exp.descricao.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(exp.descricao,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textoSuave, height: 1.4)),
          ],
        ]),
      );
}

class _FormItem extends StatelessWidget {
  final Formacao f;
  const _FormItem(this.f);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(f.curso,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.texto)),
          Text('${f.instituicao} · ${f.periodo}',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textoSuave)),
        ]),
      );
}

// ──────────────── Widgets auxiliares ────────────────
class _Label extends StatelessWidget {
  final String texto;
  const _Label(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(texto,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.texto)),
      );
}

class _CardItem extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String info;
  final VoidCallback? onEditar;
  final VoidCallback onRemover;

  const _CardItem({
    required this.titulo,
    required this.subtitulo,
    required this.info,
    this.onEditar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
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
                            color: AppColors.textoSuave, fontSize: 13)),
                    Text(info,
                        style: const TextStyle(
                            color: AppColors.textoSuave, fontSize: 12)),
                  ],
                ),
              ),
              if (onEditar != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.textoSuave),
                  onPressed: onEditar,
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.statusRejeitado),
                onPressed: onRemover,
              ),
            ],
          ),
        ),
      );
}
