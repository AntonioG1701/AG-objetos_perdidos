import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:objetos_perdidos/colores.dart';
import 'package:objetos_perdidos/services/auth_service.dart';
import 'package:objetos_perdidos/services/categorias_service.dart';
import 'package:objetos_perdidos/services/objetos_service.dart';
import 'package:objetos_perdidos/utils/validadores.dart';

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
  final categoriasStream = CategoriasService().categorias();
  final limiteFotoBytes = 900 * 1024;
  User? usuario;
  String? tipoSeleccionado;
  String? categoriaSeleccionada;
  Uint8List? fotoBytes;
  String errorFoto = '';
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    AuthService().currentUser().then((u) {
      if (!mounted) return;
      setState(() {
        usuario = u;
      });
    });
  }

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    lugarController.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto(ImageSource origen) async {
    try {
      final archivo = await ImagePicker().pickImage(
        source: origen,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );
      if (archivo == null) return;
      final bytes = await archivo.readAsBytes();
      if (!mounted) return;
      if (bytes.length > limiteFotoBytes) {
        setState(() {
          errorFoto = 'La foto pesa demasiado. Toma o elige otra.';
        });
        return;
      }
      setState(() {
        fotoBytes = bytes;
        errorFoto = '';
      });
    } catch (e) {
      debugPrint('Error al elegir foto: $e');
      if (!mounted) return;
      setState(() {
        errorFoto = 'No se pudo cargar la foto';
      });
    }
  }

  Future<void> _publicar() async {
    if (guardando) return;
    final formularioValido = _formKey.currentState!.validate();
    if (fotoBytes == null) {
      setState(() {
        errorFoto = 'Agrega una foto del objeto';
      });
    }
    if (!formularioValido || fotoBytes == null || usuario == null) return;

    setState(() {
      guardando = true;
    });
    try {
      await ObjetosService().agregarObjeto(
        tituloController.text.trim(),
        descripcionController.text.trim(),
        tipoSeleccionado!,
        categoriaSeleccionada!,
        lugarController.text.trim(),
        fotoBytes!,
        usuario!.uid,
        usuario!.displayName ?? usuario!.email ?? 'Usuario',
      );
    } catch (e) {
      debugPrint('Error al publicar: $e');
      if (!mounted) return;
      setState(() {
        guardando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo publicar. Intenta de nuevo.')),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Publicación creada')),
    );
    Navigator.pop(context);
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                validator: validarTipo,
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
                    validator: validarCategoria,
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
                validator: validarTitulo,
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
                validator: validarDescripcion,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: lugarController,
                decoration: const InputDecoration(
                  labelText: 'Lugar del campus',
                  hintText: 'Ej: Laboratorio U100',
                  border: OutlineInputBorder(),
                ),
                validator: validarLugar,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 200,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: fotoBytes == null
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 48,
                              color: Colors.black38,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Aún no hay foto',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      )
                    : Image.memory(fotoBytes!, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: guardando
                          ? null
                          : () => _elegirFoto(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Cámara'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: guardando
                          ? null
                          : () => _elegirFoto(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galería'),
                    ),
                  ),
                ],
              ),
              if (errorFoto.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  errorFoto,
                  style: const TextStyle(color: colorPerdido, fontSize: 13),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'La fecha y la hora se registran automáticamente al publicar.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: guardando ? null : _publicar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAcento,
                    foregroundColor: Colors.white,
                  ),
                  child: guardando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Publicar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}