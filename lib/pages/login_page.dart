import 'package:flutter/material.dart';
import 'package:objetos_perdidos/colores.dart';
import 'package:objetos_perdidos/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool cargando = false;
  String mensajeError = '';

  Future<void> _iniciarSesion() async {
    setState(() {
      cargando = true;
      mensajeError = '';
    });
    try {
      await AuthService().iniciarSesionConGoogle();
    } catch (e) {
      print('Error de login: $e');
      mensajeError = 'No se pudo iniciar sesión. Intenta de nuevo.';
    }
    if (!mounted) return;
    setState(() {
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Container(
              width: 112,
              height: 112,
              decoration: const BoxDecoration(
                color: colorAgregar,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'Objetos Perdidos',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: colorPrimario,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Publica lo que perdiste',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            Text(
              'o lo que encontraste en la sede',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const Spacer(flex: 3),
            mensajeError.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      mensajeError,
                      style: const TextStyle(color: colorPerdido),
                    ),
                  )
                : const SizedBox(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: cargando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _iniciarSesion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimario,
                        foregroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login),
                          SizedBox(width: 10),
                          Text('Continuar con Google'),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}