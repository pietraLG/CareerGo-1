import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/candidatura.dart';

class CandidaturasService {
  static CollectionReference<Map<String, dynamic>>? _colecao() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('candidaturas');
  }

  /// Stream que se atualiza em tempo real, ordenado pela data mais recente.
  static Stream<List<Candidatura>> observar() {
    final col = _colecao();
    if (col == null) return Stream.value([]);
    return col
        .orderBy('dataEnvio', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Candidatura.fromMap(d.data())).toList());
  }

  /// Adiciona uma candidatura nova (usa o id dela como doc id).
  static Future<void> adicionar(Candidatura c) async {
    final col = _colecao();
    if (col == null) return;
    await col.doc(c.id).set(c.toMap());
  }

  /// Atualiza apenas o campo status de uma candidatura existente.
  static Future<void> atualizarStatus(String id, String novoStatus) async {
    final col = _colecao();
    if (col == null) return;
    await col.doc(id).update({'status': novoStatus});
  }

  /// Remove uma candidatura pelo id.
  static Future<void> remover(String id) async {
    final col = _colecao();
    if (col == null) return;
    await col.doc(id).delete();
  }
}
