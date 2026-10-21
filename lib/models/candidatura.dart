class Candidatura {
  final String id;
  final String vagaId;
  final String vagaTitulo;
  final String vagaEmpresa;
  final String vagaLink;
  final String vagaLocal;
  final String status; // 'enviada' | 'analise' | 'entrevista' | 'teste' | 'aprovada' | 'rejeitada'
  final DateTime dataEnvio;
  final String observacao;

  const Candidatura({
    required this.id,
    required this.vagaId,
    required this.vagaTitulo,
    required this.vagaEmpresa,
    required this.vagaLink,
    required this.vagaLocal,
    this.status = 'enviada',
    required this.dataEnvio,
    this.observacao = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'vagaId': vagaId,
        'vagaTitulo': vagaTitulo,
        'vagaEmpresa': vagaEmpresa,
        'vagaLink': vagaLink,
        'vagaLocal': vagaLocal,
        'status': status,
        'dataEnvio': dataEnvio.toIso8601String(),
        'observacao': observacao,
      };

  factory Candidatura.fromMap(Map<String, dynamic> m) => Candidatura(
        id: m['id']?.toString() ?? '',
        vagaId: m['vagaId']?.toString() ?? '',
        vagaTitulo: m['vagaTitulo']?.toString() ?? '',
        vagaEmpresa: m['vagaEmpresa']?.toString() ?? '',
        vagaLink: m['vagaLink']?.toString() ?? '',
        vagaLocal: m['vagaLocal']?.toString() ?? '',
        status: m['status']?.toString() ?? 'enviada',
        dataEnvio: m['dataEnvio'] != null
            ? DateTime.tryParse(m['dataEnvio'].toString()) ?? DateTime.now()
            : DateTime.now(),
        observacao: m['observacao']?.toString() ?? '',
      );

  Candidatura copyWith({
    String? id,
    String? vagaId,
    String? vagaTitulo,
    String? vagaEmpresa,
    String? vagaLink,
    String? vagaLocal,
    String? status,
    DateTime? dataEnvio,
    String? observacao,
  }) =>
      Candidatura(
        id: id ?? this.id,
        vagaId: vagaId ?? this.vagaId,
        vagaTitulo: vagaTitulo ?? this.vagaTitulo,
        vagaEmpresa: vagaEmpresa ?? this.vagaEmpresa,
        vagaLink: vagaLink ?? this.vagaLink,
        vagaLocal: vagaLocal ?? this.vagaLocal,
        status: status ?? this.status,
        dataEnvio: dataEnvio ?? this.dataEnvio,
        observacao: observacao ?? this.observacao,
      );
}
