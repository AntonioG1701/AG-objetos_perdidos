import 'package:flutter/material.dart';
import 'package:objetos_perdidos/colores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:objetos_perdidos/services/categorias_service.dart';

class PublicarObjetoPage extends StatefulWidget {
  const PublicarObjetoPage({super.key});

  @override
  State<PublicarObjetoPage> createState() => _PublicarObjetoPageState();
}

class _PublicarObjetoPageState extends State<PublicarObjetoPage> {
  final _formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();
  final lugarController = TextEditingController();
  final tipos = ['Perdido', 'Encontrado'];
  String? tipoSeleccionado;
  final categoriasStream = CategoriasService().categorias();
  String? categoriaSeleccionada;

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    lugarController.dispose();
    super.dispose();
  }

  void _publicar() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formulario válido')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar objeto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: tipoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: tipos
                    .map((tipo) => DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo),
                        ))
                    .toList(),
                onChanged: (valor) {
                  setState(() {
                    tipoSeleccionado = valor;
                  });
                },
                validator: (valor) {
                  if (valor == null) {
                    return 'Selecciona si el objeto está perdido o encontrado';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: categoriasStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }
                  final categorias = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    initialValue: categoriaSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: categorias
                        .map((doc) => DropdownMenuItem(
                              value: doc['nombre'] as String,
                              child: Text(doc['nombre']),
                            ))
                        .toList(),
                    onChanged: (valor) {
                      setState(() {
                        categoriaSeleccionada = valor;
                      });
                    },
                    validator: (valor) {
                      if (valor == null) {
                        return 'Selecciona una categoría';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ej: Audífonos Bluetooth negros',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Escribe un título';
                  }
                  if (valor.trim().length < 3) {
                    return 'El título es muy corto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descripcionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Color, marca, detalles que ayuden a reconocerlo',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Escribe una descripción';
                  }
                  if (valor.trim().length < 10) {
                    return 'Describe un poco más (mínimo 10 caracteres)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: lugarController,
                decoration: const InputDecoration(
                  labelText: 'Lugar del campus',
                  hintText: 'Ej: Laboratorio U100',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Indica el lugar donde fue';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _publicar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAcento,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Publicar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}