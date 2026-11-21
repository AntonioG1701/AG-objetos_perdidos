import 'package:cloud_firestore/cloud_firestore.dart';

String formatearFecha(Timestamp fecha) {
  final f = fecha.toDate();
  final dia = f.day.toString().padLeft(2, '0');
  final mes = f.month.toString().padLeft(2, '0');
  final hora = f.hour.toString().padLeft(2, '0');
  final minuto = f.minute.toString().padLeft(2, '0');
  return '$dia/$mes/${f.year} $hora:$minuto';
}