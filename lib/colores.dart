import 'package:flutter/material.dart';

const colorPrimario = Color(0xFF4A2668);
const colorSecundario = Color(0xFF7B3FA0);
const colorAgregar = Color(0xFFFB8C00);
const colorPerdido = Color(0xFFE53935);
const colorEncontrado = Color(0xFF43A047);
const colorDevuelto = Color(0xFF9E9E9E);
const colorFondo = Color(0xFFF3EEF8);

const gradientePrincipal = LinearGradient(
  colors: [colorPrimario, colorSecundario, colorDevuelto],
  begin: Alignment.bottomRight,
  end: Alignment.topLeft,
);