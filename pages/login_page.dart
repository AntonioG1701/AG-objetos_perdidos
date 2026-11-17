import 'package:flutter/material.dart';
import 'package:objetos_perdidos/colores.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool cargando = false;
  String mensajeError = '';

  Future<void> _iniciarSesion() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const CircleAvatar(
                radius: 56,
                backgroundColor: colorAcento,
                child: Icon(Icons.search, size: 64, color: Colors.white),
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
              const Text(
                'Publica lo que perdiste o encontraste en la sede y ayuda a que vuelva a su dueño.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const Spacer(flex: 3),
              if (mensajeError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    mensajeError,
                    style: const TextStyle(color: colorPerdido),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: cargando
                    ? const Center(child: CircularProgressIndicator())
                    : OutlinedButton.icon(
                        onPressed: _iniciarSesion,
                        icon: const Icon(Icons.login),
                        label: const Text('Continuar con Google'),
                      ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}