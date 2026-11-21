import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:objetos_perdidos/colores.dart';
import 'package:objetos_perdidos/services/auth_service.dart';
import 'package:objetos_perdidos/services/objetos_service.dart';
import 'package:objetos_perdidos/utils/formato_fecha.dart';

class DetalleObjetoPage extends StatefulWidget {
  final String objetoId;

  const DetalleObjetoPage({super.key, required this.objetoId});

  @override
  State<DetalleObjetoPage> createState() => _DetalleObjetoPageState();
}

class _DetalleObjetoPageState extends State<DetalleObjetoPage> {
  User? usuario;
  bool guardando = false;
  late Stream<DocumentSnapshot> objetoStream;

  @override
  void initState() {
    super.initState();
    objetoStream = ObjetosService().objeto(widget.objetoId);
    AuthService().currentUser().then((u) {
      if (!mounted) return;
      setState(() {
        usuario = u;
      });
    });
  }

  Future<void> _marcarDevuelto() async {
    if (guardando) return;
    setState(() {
      guardando = true;
    });
    try {
      await ObjetosService().marcarDevuelto(widget.objetoId);
    } catch (e) {
      debugPrint('Error al marcar devuelto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo marcar como devuelto')),
        );
      }
    }
    if (!mounted) return;
    setState(() {
      guardando = false;
    });
  }

  Future<void> _borrar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Borrar publicación'),
          content: const Text(
            '¿Seguro que quieres borrar esta publicación? '
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: colorPerdido),
              child: const Text('Borrar'),
            ),
          ],
        );
      },
    );
    if (confirmado != true) return;

    try {
      await ObjetosService().borrarObjeto(widget.objetoId);
    } catch (e) {
      debugPrint('Error al borrar: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo borrar la publicación')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _etiqueta(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _fila(IconData icono, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 20, color: colorPrimario),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(valor, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: objetoStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final objeto = snapshot.data!;
        if (!objeto.exists) {
          return Scaffold(
            appBar: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(gradient: gradientePrincipal),
              ),
              title: const Text('Detalle del objeto'),
            ),
            body: const Center(child: Text('Esta publicación ya no existe')),
          );
        }

        final foto = (objeto['foto'] as Blob).bytes;
        final devuelto = objeto['estado'] == 'Devuelto';
        final esPerdido = objeto['tipo'] == 'Perdido';
        final esAutor = usuario != null && usuario!.uid == objeto['autorUid'];

        return Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: gradientePrincipal),
            ),
            title: const Text('Detalle del objeto'),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.black,
                  width: double.infinity,
                  height: 320,
                  child: Image.memory(foto, fit: BoxFit.contain),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _etiqueta(
                            objeto['tipo'],
                            esPerdido ? colorPerdido : colorEncontrado,
                          ),
                          const SizedBox(width: 8),
                          _etiqueta(
                            objeto['estado'],
                            devuelto ? colorDevuelto : colorPrimario,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        objeto['titulo'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorPrimario,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _fila(Icons.category, 'Categoría', objeto['categoria']),
                      _fila(Icons.place, 'Lugar', objeto['lugar']),
                      _fila(
                        Icons.event,
                        'Fecha y hora',
                        formatearFecha(objeto['fecha']),
                      ),
                      _fila(
                        Icons.person,
                        'Publicado por',
                        objeto['autorNombre'],
                      ),
                      const Divider(height: 28),
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        objeto['descripcion'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (esAutor) ...[
                        const SizedBox(height: 28),
                        if (!devuelto)
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: guardando ? null : _marcarDevuelto,
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Marcar como devuelto'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorEncontrado,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _borrar,
                            icon: const Icon(Icons.delete),
                            label: const Text('Borrar publicación'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorPerdido,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}