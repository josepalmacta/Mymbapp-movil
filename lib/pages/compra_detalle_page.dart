import 'dart:convert';

import 'package:mymbapp/data/endpoints.dart';
import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/pages/carrito.dart';
import 'package:mymbapp/utilidades/sesionToken.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:developer';

class CompraPage extends StatefulWidget {
  const CompraPage({super.key, required this.compraid});
  final String compraid;
  @override
  State<CompraPage> createState() => _CompraPageState();
}

class _CompraPageState extends State<CompraPage> {
  String token = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Compra"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                  future: getReq(widget.compraid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      log(snapshot.error.toString());
                      return Text(snapshot.error.toString());
                    }
                    if (snapshot.hasData) {
                      return CompraDetalle(
                        jsn: snapshot.data!,
                      );
                    } else {
                      return SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child:
                              const Center(child: CircularProgressIndicator()));
                    }
                  })
            ],
          ),
        ));
  }

  Future<Map> fetchCompra(String a) async {
    return await compute(getReq, a);
  }
}

class CompraDetalle extends StatelessWidget {
  const CompraDetalle({super.key, required this.jsn});

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
              Text("Compra #${jsn["ventid"]}"),
              const SizedBox(
                height: 10,
              ),
              Text(jsn["estado"]),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: listarProductos(jsn["detalle"]),
              ),
              Card(
                color: cardBackground,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Row(
                    children: [
                      const Text(
                        "Total: ",
                        style: styleBold_2,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Monto(monto: jsn["total"])
                    ],
                  ),
                ),
              ),
              Card(
                color: cardBackground,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Badge(
                        backgroundColor: primaryColor,
                        label: const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            "Datos de Facturacion",
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DetalleText(
                          titulo1: "Nombre",
                          texto1: jsn["razon"],
                          titulo2: "RUC",
                          texto2: jsn["ruc"]),
                      DetalleText(
                          titulo1: "Telefono",
                          texto1: jsn["telefono"],
                          titulo2: "Email",
                          texto2: jsn["email"]),
                      DireccionText(
                          titulo: "Direccion", texto: jsn["direccion"])
                    ],
                  ),
                ),
              ),
              SizedBox(
                  height: 300,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Stack(children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(double.parse(jsn["lat"]),
                              double.parse(jsn["lng"])),
                          initialZoom: 15,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          ),
                          RichAttributionWidget(
                            // Include a stylish prebuilt attribution widget that meets all requirments
                            attributions: [
                              TextSourceAttribution('OpenStreetMap',
                                  onTap: () {}),
                              TextSourceAttribution('Leaflet',
                                  onTap: () {}), // (external)
                              // Also add images...
                            ],
                          ),
                          MarkerLayer(markers: [
                            Marker(
                                point: LatLng(double.parse(jsn["lat"]),
                                    double.parse(jsn["lng"])),
                                child: Icon(
                                  Icons.place,
                                  color: primaryColor,
                                  size: 50,
                                ))
                          ])
                        ],
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Badge(
                          backgroundColor: primaryColor,
                          label: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text("Delivery"),
                          ),
                        ),
                      )
                    ]),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

Future<Map> getReq(String a) async {
  String? token = await getToken();
  if (token == null) {
    return {};
  }
  String resp = "[]";
  Map<String, String> JsonBody = {'cid': a, 'device': 'app', 'token': token};
  var result = await http.post(Uri.parse(MI_COMPRA), body: JsonBody);
  if (result.statusCode == 200) {
    // If you are sure that your web service has json string, return it directly
    resp = result.body;
  }
  return json.decode(resp);
}

List<Widget> listarProductos(List p) {
  List<Widget> prods = [];

  for (var element in p) {
    prods.add(Producto(elem: element));
  }

  return prods;
}

class Producto extends StatelessWidget {
  const Producto({super.key, required this.elem});

  final Map elem;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
                width: 100,
                height: 100,
                child: Image.network(
                    fit: BoxFit.cover, "$URL_GLOBAL${elem["img"]}")),
            const SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  elem["nombre"],
                  style: styleBoldB_3,
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Monto(monto: elem["precio"]),
                    const SizedBox(
                      width: 15,
                    ),
                    Row(
                      children: [
                        const Text("Cantidad:"),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(elem["cantidad"])
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Text(
                      "Subtotal:",
                      style: styleBold_2,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Monto(monto: elem["subtotal"]),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DetalleText extends StatelessWidget {
  const DetalleText(
      {super.key,
      required this.titulo1,
      required this.texto1,
      required this.titulo2,
      required this.texto2});
  final String titulo1;
  final String texto1;
  final String titulo2;
  final String texto2;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titulo1,
                style: styleBold,
              ),
            ),
            Expanded(
                child: Text(
              titulo2,
              style: styleBold,
            ))
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                texto1,
                style: styleNormal,
              ),
            ),
            Expanded(
                child: Text(
              texto2,
              style: styleNormal,
            ))
          ],
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }
}

class DireccionText extends StatelessWidget {
  const DireccionText({
    super.key,
    required this.titulo,
    required this.texto,
  });
  final String titulo;
  final String texto;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: styleBold,
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 20),
          child: Text(
            texto,
            style: styleNormal,
          ),
        ),
      ],
    );
  }
}
