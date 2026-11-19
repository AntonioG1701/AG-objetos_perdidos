import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriasService{
  Stream<QuerySnapshot> categorias(){
    return FirebaseFirestore.instance
    .collection('categorias')
    .orderBy('orden')
    .snapshots();
  }
}