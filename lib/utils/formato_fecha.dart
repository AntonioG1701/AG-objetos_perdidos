import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatearFecha(Timestamp fecha) {
  return DateFormat('dd/MM/yyyy HH:mm').format(fecha.toDate());
}