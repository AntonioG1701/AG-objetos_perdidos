import 'package:flutter/material.dart';
import 'package:objetos_perdidos/colores.dart';
import 'package:objetos_perdidos/pages/publicar_objeto_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objetos Perdidos'),
      ),
      body: const Center(
        child: Text('lista de objetos'),
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