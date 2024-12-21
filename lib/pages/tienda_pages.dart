import 'dart:convert';

import 'package:mymbapp/data/endpoints.dart';
import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/data/lista_carrito.dart';
import 'package:mymbapp/pages/carrito.dart';
import 'package:mymbapp/widgets/card_productos.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class TiendaPage extends StatefulWidget {
  const TiendaPage({super.key});

  @override
  State<TiendaPage> createState() => _TiendaPageState();
}

class _TiendaPageState extends State<TiendaPage> {
  String? pagina = "0";

  List productos = [];

  bool cargando = false;

  @override
  void initState() {
    super.initState();
    getReq();
  }

  Future<void> getReq() async {
    String resp = "[]";
    setState(() {
      cargando = true;
    });
    Map<String, String> parametros = {"pagina": pagina!};
    var result = await http.post(Uri.parse(PRODUCTO_LIST), body: parametros);
    if (result.statusCode == 200) {
      resp = result.body;
    }
    int pag = int.parse(pagina!) + 8;
    pagina = pag.toString();
    List lst = json.decode(resp);
    if (lst.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No hay mas productos")));
    }
    setState(() {
      cargando = false;
      productos.addAll(lst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModelProd(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Tienda"),
          actions: [
            Stack(children: [
              IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CarritoPage()));
                  },
                  icon: primaryIconButton(Icons.shopping_cart_rounded)),
              Carrito()
            ])
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 50),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Número de columnas
                            crossAxisSpacing: 5.0, // Espaciado horizontal
                            mainAxisSpacing: 5.0, // Espaciado vertical
                            childAspectRatio: 0.66),
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      Map elem = productos[index];
                      return CardProd(
                          prodid: elem["prodid"],
                          nombre: elem["nombre"],
                          descripcion: elem["descripcion"],
                          imagen: "$PRODUCTO_IMG/${elem["img"]}",
                          stock: elem["stock"],
                          precio: elem["precio"],
                          indice: index.toString());
                    },
                  ),
                ),
              ),
              if (cargando)
                const SizedBox(
                  height: 500,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (!cargando)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      getReq();
                    },
                    icon: primaryIconButton(Icons.restart_alt_outlined),
                    label: Text(
                      "Cargar mas productos",
                      style: primaryButtonText,
                    ),
                    style: primaryButton,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class Carrito extends StatefulWidget {
  const Carrito({
    super.key,
  });

  @override
  State<Carrito> createState() => _CarritoState();
}

class _CarritoState extends State<Carrito> {
  @override
  void initState() {
    super.initState();
    ModelProd model = Provider.of<ModelProd>(context, listen: false);
    model.getCarrito();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelProd>(builder: (context, value, child) {
      return Badge(
        label: Text(value.carrito),
      );
    });
  }
}
