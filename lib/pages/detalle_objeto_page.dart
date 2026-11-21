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
      print('Error al marcar devuelto: $e');
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

  void _borrar() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar publicación'),
        content: const Text(
          '¿Seguro que quieres borrar esta publicación? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (guardando) return;
              guardando = true;

              try {
                final messenger = ScaffoldMessenger.of(context);

                await ObjetosService().borrarObjeto(widget.objetoId);

                if (!mounted || !dialogContext.mounted) {
                  return;
                }

                messenger.showSnackBar(
                  const SnackBar(content: Text('Publicación borrada')),
                );

                Navigator.pop(dialogContext);
                Navigator.pop(context);
              } catch (e) {
                print('Error al borrar: $e');
                if (!mounted || !dialogContext.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo borrar la publicación'),
                  ),
                );
              } finally {
                guardando = false;
              }
            },
            style: FilledButton.styleFrom(backgroundColor: colorPerdido),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
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
            backgroundColor: colorFondo,
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
          backgroundColor: colorFondo,
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
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.category,
                          color: colorPrimario,
                        ),
                        title: Text(
                          'Categoría',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        subtitle: Text(
                          objeto['categoria'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.place,
                          color: colorPrimario,
                        ),
                        title: Text(
                          'Lugar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        subtitle: Text(
                          objeto['lugar'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.event,
                          color: colorPrimario,
                        ),
                        title: Text(
                          'Fecha y hora',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        subtitle: Text(
                          formatearFecha(objeto['fecha']),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.person,
                          color: colorPrimario,
                        ),
                        title: Text(
                          'Publicado por',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        subtitle: Text(
                          objeto['autorNombre'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Divider(height: 28),
                      Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        objeto['descripcion'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      esAutor
                          ? Column(
                              children: [
                                const SizedBox(height: 28),
                                devuelto
                                    ? const SizedBox()
                                    : SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed: _marcarDevuelto,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colorEncontrado,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check_circle),
                                              SizedBox(width: 8),
                                              Text('Marcar como devuelto'),
                                            ],
                                          ),
                                        ),
                                      ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _borrar,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorPerdido,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.delete),
                                        SizedBox(width: 8),
                                        Text('Borrar publicación'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(),
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