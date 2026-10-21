import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/curriculo.dart';

class CurriculoService {
  static DocumentReference<Map<String, dynamic>>? _doc() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('curriculo')
        .doc('dados');
  }

  /// Carrega o currículo salvo. Retorna null se ainda não existir.
  static Future<Curriculo?> carregar() async {
    final ref = _doc();
    if (ref == null) return null;
    final snap = await ref.get();
    if (!snap.exists || snap.data() == null) return null;
    return Curriculo.fromMap(snap.data()!);
  }

  /// Salva (ou atualiza) o currículo no Firestore.
  static Future<void> salvar(Curriculo c) async {
    final ref = _doc();
    if (ref == null) return;
    await ref.set(c.toMap(), SetOptions(merge: true));
  }
}
