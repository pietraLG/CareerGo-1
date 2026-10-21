class Experiencia {
  final String cargo;
  final String empresa;
  final String periodo;
  final String descricao;

  const Experiencia({
    this.cargo = '',
    this.empresa = '',
    this.periodo = '',
    this.descricao = '',
  });

  Map<String, dynamic> toMap() => {
        'cargo': cargo,
        'empresa': empresa,
        'periodo': periodo,
        'descricao': descricao,
      };

  factory Experiencia.fromMap(Map<String, dynamic> m) => Experiencia(
        cargo: m['cargo']?.toString() ?? '',
        empresa: m['empresa']?.toString() ?? '',
        periodo: m['periodo']?.toString() ?? '',
        descricao: m['descricao']?.toString() ?? '',
      );

  Experiencia copyWith({
    String? cargo,
    String? empresa,
    String? periodo,
    String? descricao,
  }) =>
      Experiencia(
        cargo: cargo ?? this.cargo,
        empresa: empresa ?? this.empresa,
        periodo: periodo ?? this.periodo,
        descricao: descricao ?? this.descricao,
      );
}

class Formacao {
  final String curso;
  final String instituicao;
  final String periodo;

  const Formacao({
    this.curso = '',
    this.instituicao = '',
    this.periodo = '',
  });

  Map<String, dynamic> toMap() => {
        'curso': curso,
        'instituicao': instituicao,
        'periodo': periodo,
      };

  factory Formacao.fromMap(Map<String, dynamic> m) => Formacao(
        curso: m['curso']?.toString() ?? '',
        instituicao: m['instituicao']?.toString() ?? '',
        periodo: m['periodo']?.toString() ?? '',
      );

  Formacao copyWith({String? curso, String? instituicao, String? periodo}) =>
      Formacao(
        curso: curso ?? this.curso,
        instituicao: instituicao ?? this.instituicao,
        periodo: periodo ?? this.periodo,
      );
}

class Idioma {
  final String nome;
  final String nivel; // Básico | Intermediário | Avançado | Fluente

  const Idioma({this.nome = '', this.nivel = 'Básico'});

  Map<String, dynamic> toMap() => {'nome': nome, 'nivel': nivel};

  factory Idioma.fromMap(Map<String, dynamic> m) => Idioma(
        nome: m['nome']?.toString() ?? '',
        nivel: m['nivel']?.toString() ?? 'Básico',
      );

  Idioma copyWith({String? nome, String? nivel}) =>
      Idioma(nome: nome ?? this.nome, nivel: nivel ?? this.nivel);
}

class Curriculo {
  final String objetivo;
  final String telefone;
  final String linkedin;
  final String github;
  final String cidade;
  final List<Experiencia> experiencias;
  final List<Formacao> formacoes;
  final List<String> habilidades;
  final List<Idioma> idiomas;

  const Curriculo({
    this.objetivo = '',
    this.telefone = '',
    this.linkedin = '',
    this.github = '',
    this.cidade = '',
    this.experiencias = const [],
    this.formacoes = const [],
    this.habilidades = const [],
    this.idiomas = const [],
  });

  Map<String, dynamic> toMap() => {
        'objetivo': objetivo,
        'telefone': telefone,
        'linkedin': linkedin,
        'github': github,
        'cidade': cidade,
        'experiencias': experiencias.map((e) => e.toMap()).toList(),
        'formacoes': formacoes.map((f) => f.toMap()).toList(),
        'habilidades': habilidades,
        'idiomas': idiomas.map((i) => i.toMap()).toList(),
      };

  factory Curriculo.fromMap(Map<String, dynamic> m) => Curriculo(
        objetivo: m['objetivo']?.toString() ?? '',
        telefone: m['telefone']?.toString() ?? '',
        linkedin: m['linkedin']?.toString() ?? '',
        github: m['github']?.toString() ?? '',
        cidade: m['cidade']?.toString() ?? '',
        experiencias: (m['experiencias'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .map(Experiencia.fromMap)
            .toList(),
        formacoes: (m['formacoes'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .map(Formacao.fromMap)
            .toList(),
        habilidades: (m['habilidades'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        idiomas: (m['idiomas'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .map(Idioma.fromMap)
            .toList(),
      );

  Curriculo copyWith({
    String? objetivo,
    String? telefone,
    String? linkedin,
    String? github,
    String? cidade,
    List<Experiencia>? experiencias,
    List<Formacao>? formacoes,
    List<String>? habilidades,
    List<Idioma>? idiomas,
  }) =>
      Curriculo(
        objetivo: objetivo ?? this.objetivo,
        telefone: telefone ?? this.telefone,
        linkedin: linkedin ?? this.linkedin,
        github: github ?? this.github,
        cidade: cidade ?? this.cidade,
        experiencias: experiencias ?? this.experiencias,
        formacoes: formacoes ?? this.formacoes,
        habilidades: habilidades ?? this.habilidades,
        idiomas: idiomas ?? this.idiomas,
      );
}
