import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Crea una instancia de FlutterSecureStorage
final FlutterSecureStorage secureStorage = FlutterSecureStorage();

// Función para obtener el token desde el almacenamiento seguro
Future<String?> getToken() async {
  return await secureStorage.read(key: 'jwt_token');
}

// Función para guardar el token en el almacenamiento seguro
Future<void> saveToken(String token) async {
  await secureStorage.write(key: 'jwt_token', value: token);
}

// Función para eliminar el token (por ejemplo, al cerrar sesión)
Future<void> deleteToken() async {
  await secureStorage.delete(key: 'jwt_token');
}
