import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/adzuna_config.dart';
import '../models/vaga.dart';

class AdzunaService {
  static const _base = 'api.adzuna.com';

  /// Busca vagas na API da Adzuna (Brasil).
  /// [busca] — termo livre (vazio = todas as vagas).
  /// [categoria] — tag da categoria (ex: 'it-jobs'). null = todas.
  /// [pagina] — número da página, começa em 1.
  static Future<List<Vaga>> buscar({
    String busca = '',
    String? categoria,
    int pagina = 1,
  }) async {
    final params = <String, String>{
      'app_id': AdzunaConfig.appId,
      'app_key': AdzunaConfig.appKey,
      'results_per_page': '20',
      // O número da página já vai na URL; não repetir aqui.
      if (busca.isNotEmpty) 'what': busca,
      'category': ?categoria,
    };

    final uri = Uri.https(_base, '/v1/api/jobs/br/search/$pagina', params);
    final resposta = await http
        .get(uri, headers: {'Accept': 'application/json'}).timeout(
      const Duration(seconds: 15),
    );

    if (resposta.statusCode != 200) {
      throw Exception('Adzuna ${resposta.statusCode}: ${resposta.body}');
    }

    final json = jsonDecode(resposta.body) as Map<String, dynamic>;
    final resultados = json['results'] as List<dynamic>? ?? [];
    return resultados
        .cast<Map<String, dynamic>>()
        .map(Vaga.fromJson)
        .toList();
  }
}
