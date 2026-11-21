import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:objetos_perdidos/colores.dart';

class ObjetoCard extends StatelessWidget {
  final String titulo;
  final String tipo;
  final String categoria;
  final String estado;
  final Uint8List foto;
  final Function onTap;

  const ObjetoCard({
    super.key,
    required this.titulo,
    required this.tipo,
    required this.categoria,
    required this.estado,
    required this.foto,
    required this.onTap,
  });

  Widget _etiqueta(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devuelto = estado == 'Devuelto';
    final esPerdido = tipo == 'Perdido';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: devuelto ? Colors.grey.shade200 : Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () => onTap(),
        contentPadding: const EdgeInsets.all(10),
        leading: Container(
          width: 72,
          height: 72,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Image.memory(foto, fit: BoxFit.cover),
        ),
        title: Text(
          titulo,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: devuelto ? Colors.grey.shade600 : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                _etiqueta(tipo, esPerdido ? colorPerdido : colorEncontrado),
                const SizedBox(width: 6),
                _etiqueta(estado, devuelto ? colorDevuelto : colorPrimario),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              categoria,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}