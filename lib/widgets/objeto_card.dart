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

    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.memory(foto, fit: BoxFit.cover),
            ),
            devuelto
                ? Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(color: Colors.white54),
                  )
                : const SizedBox(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      categoria,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _etiqueta(tipo, esPerdido ? colorPerdido : colorEncontrado),
                  const SizedBox(height: 4),
                  _etiqueta(estado, devuelto ? colorDevuelto : colorPrimario),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

