String? validar(String? valor) {
  if (valor == null || valor.isEmpty) {
    return "Este campo es obligatorio";
  }
  return null;
}

String? validarEmail(String? valor) {
  if (valor == null || valor.isEmpty) {
    return "Este campo es obligatorio";
  }
  final formato = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!formato.hasMatch(valor)) {
    return "El email ingresado no es valido";
  }
  return null;
}

String? validarTelefono(String? valor) {
  if (valor == null || valor.isEmpty) {
    return "Este campo es obligatorio";
  }
  final formato = RegExp(r'^09[6-9][1-6][0-9]{6}$');
  if (!formato.hasMatch(valor)) {
    return "El telefono ingresado no es valido";
  }
  return null;
}

String? validarRuc(String? valor) {
  if (valor == null || valor.isEmpty) {
    return "Este campo es obligatorio";
  }
  final formato = RegExp(r'^[0-9]{7,8}\-[0-9]{1}$');
  final formato2 = RegExp(r'^[0-9]{6,7}$');
  if (!formato.hasMatch(valor) && !formato2.hasMatch(valor)) {
    return "El CI o RUC ingresado no es valido";
  }
  return null;
}

String? validarPassw(String? valor) {
  if (valor == null || valor.isEmpty) {
    return "Este campo es obligatorio";
  }
  if (valor.length < 8) {
    return "La contraseña debe ser de por lo menos 8 caracteres";
  }
  return null;
}
