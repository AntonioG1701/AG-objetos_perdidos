String? validarTipo(String? valor) {
  if (valor == null) {
    return 'Selecciona si el objeto está perdido o encontrado';
  }
  return null;
}

String? validarCategoria(String? valor) {
  if (valor == null) {
    return 'Selecciona una categoría';
  }
  return null;
}

String? validarTitulo(String? valor) {
  if (valor == null || valor.trim().isEmpty) {
    return 'Escribe un título';
  }
  if (valor.trim().length < 3) {
    return 'El título es muy corto';
  }
  return null;
}

String? validarDescripcion(String? valor) {
  if (valor == null || valor.trim().isEmpty) {
    return 'Escribe una descripción';
  }
  if (valor.trim().length < 10) {
    return 'Describe un poco más (mínimo 10 caracteres)';
  }
  return null;
}

String? validarLugar(String? valor) {
  if (valor == null || valor.trim().isEmpty) {
    return 'Indica el lugar donde fue';
  }
  return null;
}