import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:objetos_perdidos/colores.dart';

class ObjetoCard extends StatelessWidget {
  final QueryDocumentSnapshot objeto;
  final VoidCallback onTap;

  const ObjetoCard({super.key, required this.objeto, required this.onTap});

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
    final foto = (objeto['foto'] as Blob).bytes;
    final devuelto = objeto['estado'] == 'Devuelto';
    final esPerdido = objeto['tipo'] == 'Perdido';

    return Opacity(
      opacity: devuelto ? 0.55 : 1,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    foto,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    cacheWidth: 200,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        objeto['titulo'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration:
                              devuelto ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _etiqueta(
                            objeto['tipo'],
                            esPerdido ? colorPerdido : colorEncontrado,
                          ),
                          const SizedBox(width: 6),
                          _etiqueta(
                            objeto['estado'],
                            devuelto ? colorDevuelto : colorPrimario,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        objeto['categoria'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}










