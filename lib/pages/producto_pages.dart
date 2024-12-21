import 'dart:convert';

import 'package:mymbapp/data/endpoints.dart';
import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/data/lista_carrito.dart';
import 'package:mymbapp/pages/carrito.dart';
import 'package:mymbapp/utilidades/sesionToken.dart';
import 'package:mymbapp/widgets/carousel_producto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProductoPage extends StatefulWidget {
  const ProductoPage({super.key, required this.prodid});
  final String prodid;
  @override
  State<ProductoPage> createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModelProd(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Producto"),
            actions: [
              Stack(children: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CarritoPage()));
                    },
                    icon: primaryIconButton(Icons.shopping_cart_rounded)),
                Carrito()
              ])
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder(
                    future: fetchPosts(widget.prodid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return PostBody(
                          jsn: snapshot.data!,
                        );
                      } else {
                        return SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: const Center(
                                child: CircularProgressIndicator()));
                      }
                    })
              ],
            ),
          )),
    );
  }

  Future<Map> fetchPosts(String a) async {
    return await compute(getReq, a);
  }
}

class Carrito extends StatelessWidget {
  const Carrito({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelProd>(builder: (context, value, child) {
      return Badge(
        label: Text(value.carrito),
      );
    });
  }
}

class PostBody extends StatelessWidget {
  const PostBody({super.key, required this.jsn});

  final Map jsn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              CarouselProducto(jsn: jsn["imgs"]),
              Card(
                color: cardBackground,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jsn["nombre"],
                        style: styleBoldB_2,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.currency_bitcoin,
                            size: 15,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            jsn["precio"],
                            style: styleBold,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        "Descripcion",
                        style: styleNormal,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        constraints: const BoxConstraints(minHeight: 40),
                        child: Text(jsn["descripcion"]),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Disponible",
                            style: styleSmall_2,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            jsn["stock"],
                            style: styleSmall_2,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Cantidad(stock: jsn["stock"]),
                      const SizedBox(
                        height: 50,
                      ),
                      Center(
                        child: ElevatedButton.icon(
                            style: primaryButton,
                            icon: primaryIconButton(Icons.add_shopping_cart),
                            onPressed: () async {
                              String? token = await getToken();
                              if (token == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Debe iniciar sesion")));
                                return;
                              }
                              final model = Provider.of<ModelProd>(context,
                                  listen: false);
                              Map r = await agregarCarrito(jsn["id"],
                                  model.cantidad, jsn["precio"], token);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(r["mensaje"])));
                              if (r["success"]) {
                                model.getCarrito();
                              }
                            },
                            label: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Agregar al carrito",
                                style: primaryButtonText,
                              ),
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<Map> getReq(String a) async {
  String resp = "[]";
  Map<String, String> JsonBody = {
    'producto': a,
  };
  var result = await http.post(Uri.parse(PRODUCTO_SHOW), body: JsonBody);
  if (result.statusCode == 200) {
    // If you are sure that your web service has json string, return it directly
    resp = result.body;
  }
  //log(resp);
  return json.decode(resp);
}

Future<Map> agregarCarrito(String a, b, c, t) async {
  String resp = "[]";
  Map<String, String> JsonBody = {
    'producto': a,
    'cantidad': b,
    'precio': c,
    'device': 'app',
    'token': t
  };
  var result = await http.post(Uri.parse(CARRITO_ADD), body: JsonBody);
  if (result.statusCode == 200) {
    // If you are sure that your web service has json string, return it directly
    resp = result.body;
  }
  return json.decode(resp);
}

class Cantidad extends StatefulWidget {
  const Cantidad({super.key, required this.stock});
  final String stock;
  @override
  State<Cantidad> createState() => _CantidadState();
}

class _CantidadState extends State<Cantidad> {
  @override
  void initState() {
    super.initState();
    final model = Provider.of<ModelProd>(context, listen: false);
    model.getCarrito();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelProd>(builder: (context, value, child) {
      return Row(
        children: [
          IconButton(
              style: primaryButton,
              onPressed: () {
                int a = int.parse(value.cantidad);
                if (a <= 1) {
                  return;
                }
                value.agregar((a - 1).toString());
              },
              icon: primaryIconButton(Icons.remove)),
          const SizedBox(
            width: 10,
          ),
          Badge(
            backgroundColor: Colors.grey,
            label: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(value.cantidad),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          IconButton(
              style: primaryButton,
              onPressed: () {
                int a = int.parse(value.cantidad);
                int b = int.parse(widget.stock);
                if (a >= b) {
                  return;
                }
                value.agregar((a + 1).toString());
              },
              icon: primaryIconButton(Icons.add)),
        ],
      );
    });
  }
}
