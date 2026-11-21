import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:objetos_perdidos/colores.dart';
import 'package:objetos_perdidos/pages/detalle_objeto_page.dart';
import 'package:objetos_perdidos/pages/mis_publicaciones_page.dart';
import 'package:objetos_perdidos/pages/publicar_objeto_page.dart';
import 'package:objetos_perdidos/services/auth_service.dart';
import 'package:objetos_perdidos/services/objetos_service.dart';
import 'package:objetos_perdidos/widgets/objeto_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? usuario;
  final objetosStream = ObjetosService().objetos();

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

  Future<void> _cerrarSesion() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Quieres cerrar tu sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
    if (confirmado != true) return;
    await AuthService().cerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: gradientePrincipal),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Objetos Perdidos'),
            Text(
              usuario?.displayName ?? 'Cargando...',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_shared),
            tooltip: 'Mis publicaciones',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MisPublicacionesPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: objetosStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final objetos = snapshot.data!.docs;

          if (objetos.isEmpty) {
            return const Center(child: Text('Aún no hay publicaciones'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 6, bottom: 90),
            itemCount: objetos.length,
            itemBuilder: (context, index) {
              final objeto = objetos[index];
              return ObjetoCard(
                objeto: objeto,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetalleObjetoPage(objetoId: objeto.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PublicarObjetoPage()),
          );
        },
        backgroundColor: colorAcento,
        foregroundColor: Colors.white,
        tooltip: 'Publicar objeto',
        child: const Icon(Icons.add),
      ),
    );
  }
}