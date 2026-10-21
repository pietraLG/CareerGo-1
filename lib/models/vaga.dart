class Vaga {
  final String id;
  final String titulo;
  final String empresa;
  final String local;
  final String descricao;
  final String categoria;
  final String? contrato; // "Full-time" ou "Meio período"
  final String? modalidade; // "Remoto", "Híbrido" ou null
  final double? salarioMin;
  final double? salarioMax;
  final bool salarioEstimado;
  final String link;

  const Vaga({
    required this.id,
    required this.titulo,
    required this.empresa,
    required this.local,
    required this.descricao,
    required this.categoria,
    required this.contrato,
    required this.modalidade,
    required this.salarioMin,
    required this.salarioMax,
    required this.salarioEstimado,
    required this.link,
  });

  // Converte o JSON da Adzuna em uma Vaga
  factory Vaga.fromJson(Map<String, dynamic> json) {
    String limpar(Object? texto) =>
        (texto ?? '').toString().replaceAll(RegExp(r'<[^>]*>'), '').trim();

    final titulo = limpar(json['title']);
    final descricao = limpar(json['description']);
    final texto = '$titulo $descricao'.toLowerCase();

    String? modalidade;
    if (texto.contains('remoto') ||
        texto.contains('home office') ||
        texto.contains('home-office')) {
      modalidade = 'Remoto';
    } else if (texto.contains('híbrido') || texto.contains('hibrido')) {
      modalidade = 'Híbrido';
    }

    String? contrato;
    final contratoBruto = json['contract_time'];
    if (contratoBruto == 'full_time') {
      contrato = 'Full-time';
    } else if (contratoBruto == 'part_time') {
      contrato = 'Meio período';
    }

    final empresa = limpar(
        (json['company'] as Map<String, dynamic>?)?['display_name']);
    final local = limpar(
        (json['location'] as Map<String, dynamic>?)?['display_name']);
    final categoria =
        limpar((json['category'] as Map<String, dynamic>?)?['label']);

    // A Adzuna estima salários em muitas vagas. Só usamos os informados de verdade.
    final estimado = json['salary_is_predicted']?.toString() == '1';

    return Vaga(
      id: json['id']?.toString() ?? '',
      titulo: titulo,
      empresa: empresa.isEmpty ? 'Empresa não informada' : empresa,
      local: local.isEmpty ? 'Brasil' : local,
      descricao: descricao,
      categoria: categoria,
      contrato: contrato,
      modalidade: modalidade,
      salarioMin: estimado ? null : (json['salary_min'] as num?)?.toDouble(),
      salarioMax: estimado ? null : (json['salary_max'] as num?)?.toDouble(),
      salarioEstimado: false,
      link: json['redirect_url']?.toString() ?? '',
    );
  }

  // Dados da vaga para guardar no Firestore
  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'empresa': empresa,
        'local': local,
        'descricao': descricao,
        'categoria': categoria,
        'contrato': contrato,
        'modalidade': modalidade,
        'salarioMin': salarioMin,
        'salarioMax': salarioMax,
        'link': link,
      };

  // Lê a vaga guardada no Firestore
  factory Vaga.fromMap(Map<String, dynamic> m) => Vaga(
        id: m['id']?.toString() ?? '',
        titulo: m['titulo']?.toString() ?? '',
        empresa: m['empresa']?.toString() ?? '',
        local: m['local']?.toString() ?? '',
        descricao: m['descricao']?.toString() ?? '',
        categoria: m['categoria']?.toString() ?? '',
        contrato: m['contrato'] as String?,
        modalidade: m['modalidade'] as String?,
        salarioMin: (m['salarioMin'] as num?)?.toDouble(),
        salarioMax: (m['salarioMax'] as num?)?.toDouble(),
        salarioEstimado: false,
        link: m['link']?.toString() ?? '',
      );

  // Texto do salário, como no design: "R$ 4.000 - R$ 6.000"
  String get salarioTexto {
    if (salarioMin == null && salarioMax == null) return 'Salário a combinar';
    String valor;
    if (salarioMin != null && salarioMax != null && salarioMin != salarioMax) {
      valor = '${_real(salarioMin!)} - ${_real(salarioMax!)}';
    } else {
      valor = _real((salarioMin ?? salarioMax)!);
    }
    return salarioEstimado ? '$valor (estimado)' : valor;
  }

  static String _real(double valor) {
    final inteiro = valor.round().toString();
    final comPontos = inteiro.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'R\$ $comPontos';
  }
}