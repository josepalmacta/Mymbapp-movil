import 'package:mymbapp/data/endpoints.dart';
import 'package:mymbapp/utilidades/sesionToken.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ModelProd with ChangeNotifier {
  String cantidad = "1";

  String carrito = "0";

  String? token;

  void setToken(String ntoken) {
    token = ntoken;
    notifyListeners();
  }

  void agregar(ncantidad) {
    cantidad = ncantidad;
    notifyListeners();
  }

  Future<void> getCarrito() async {
    String? token = await getToken();
    if (token == null) {
      return;
    }
    Map<String, String> JsonBody = {'device': 'app', 'token': token};
    var result = await http.post(Uri.parse(CARRITO_CANT), body: JsonBody);
    if (result.statusCode == 200) {
      // If you are sure that your web service has json string, return it directly
      String resp = result.body;

      carrito = resp.trim();
      notifyListeners();
    }
    //log(resp);
  }
}
