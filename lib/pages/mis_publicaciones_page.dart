import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:objetos_perdidos/colores.dart';
import 'package:objetos_perdidos/pages/detalle_objeto_page.dart';
import 'package:objetos_perdidos/services/auth_service.dart';
import 'package:objetos_perdidos/services/objetos_service.dart';
import 'package:objetos_perdidos/widgets/objeto_card.dart';

class MisPublicacionesPage extends StatefulWidget {
  const MisPublicacionesPage({super.key});

  @override
  State<MisPublicacionesPage> createState() => _MisPublicacionesPageState();
}

class _MisPublicacionesPageState extends State<MisPublicacionesPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: gradientePrincipal),
        ),
        title: const Text('Mis publicaciones'),
      ),
      body: usuario == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: objetosStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final misObjetos = snapshot.data!.docs
                    .where((doc) => doc['autorUid'] == usuario!.uid)
                    .toList();

                if (misObjetos.isEmpty) {
                  return const Center(
                    child: Text('Todavía no has publicado nada'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 6, bottom: 20),
                  itemCount: misObjetos.length,
                  itemBuilder: (context, index) {
                    final objeto = misObjetos[index];
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
    );
  }
}








