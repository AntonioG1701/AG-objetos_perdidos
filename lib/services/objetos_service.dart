import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class ObjetosService {
  Stream<QuerySnapshot> objetos() {
    return FirebaseFirestore.instance
        .collection('objetos')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot> objeto(String id) {
    return FirebaseFirestore.instance
        .collection('objetos')
        .doc(id)
        .snapshots();
  }

  Future<void> agregarObjeto(
    String titulo,
    String descripcion,
    String tipo,
    String categoria,
    String lugar,
    Uint8List foto,
    String autorUid,
    String autorNombre,
  ) {
    return FirebaseFirestore.instance.collection('objetos').doc().set({
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'categoria': categoria,
      'lugar': lugar,
      'fecha': Timestamp.now(),
      'foto': Blob(foto),
      'estado': 'Vigente',
      'autorUid': autorUid,
      'autorNombre': autorNombre,
    });
  }

  Future<void> marcarDevuelto(String id) {
    return FirebaseFirestore.instance
        .collection('objetos')
        .doc(id)
        .update({'estado': 'Devuelto'});
  }

  Future<void> borrarObjeto(String id) {
    return FirebaseFirestore.instance.collection('objetos').doc(id).delete();
  }
}



