import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vaga.dart';

class FavoritosService {
  // Pasta de favoritos do usuário que está logado
  static CollectionReference<Map<String, dynamic>>? _colecao() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('favoritos');
  }

  // Lista de favoritos que se atualiza sozinha
  static Stream<List<Vaga>> observar() {
    final colecao = _colecao();
    if (colecao == null) return Stream.value([]);
    return colecao
        .orderBy('salvoEm', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Vaga.fromMap(d.data())).toList());
  }

  // Se já era favorita, remove. Se não era, salva.
  static Future<void> alternar(Vaga vaga, {required bool jaFavorita}) async {
    final colecao = _colecao();
    if (colecao == null || vaga.id.isEmpty) return;
    final doc = colecao.doc(vaga.id);
    if (jaFavorita) {
      await doc.delete();
    } else {
      await doc.set({
        ...vaga.toMap(),
        'salvoEm': FieldValue.serverTimestamp(),
      });
    }
  }
}