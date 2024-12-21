import 'dart:convert';
import 'package:mymbapp/data/endpoints.dart';
import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/utilidades/metodos.dart';
import 'package:mymbapp/utilidades/sesionToken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

final razonSocial = TextEditingController();
final ciruc = TextEditingController();
final telefono = TextEditingController();
final direccion = TextEditingController();
final email = TextEditingController();

final _formkey = GlobalKey<FormState>();

class ModelCarrito with ChangeNotifier {
  List<Map> carrito = [];

  Map datos = {};

  void eliminarMascota(int index) {
    carrito.removeAt(index);
    notifyListeners();
  }

  void pasarImagenes(Map imas) {
    carrito.add(imas);
    log("Imagen agregada, notificando...");
    notifyListeners();
  }

  void agregarCampos(Map<String, String> campos) {
    campos.forEach((key, value) {
      datos[key] = value;
    });
    notifyListeners();
  }

  void eliminarCampos(Map<String, String> campos) {
    campos.forEach((key, value) {
      datos.remove(key);
    });
    notifyListeners();
  }
}

class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModelCarrito(),
      child: DefaultTabController(
          length: 4,
          child: Scaffold(
              appBar: AppBar(
                title: const Text("Carrito de compras"),
              ),
              body: MyTabs())),
    );
  }
}

class MyTabs extends StatefulWidget {
  const MyTabs({
    super.key,
  });

  @override
  State<MyTabs> createState() => _MyTabsState();
}

class _MyTabsState extends State<MyTabs> {
  @override
  Widget build(BuildContext context) {
    return TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        children: [TabCarrito(), TabDatos(), TabUbicacion(), TabPagar()]);
  }
}

class TabCarrito extends StatefulWidget {
  const TabCarrito({super.key});

  @override
  State<TabCarrito> createState() => _TabCarritoState();
}

class _TabCarritoState extends State<TabCarrito> {
  List carrito = [];
  String total = "";
  String ventid = "";

  @override
  void initState() {
    super.initState();
    getReq();
  }

  Future<void> getReq() async {
    String? token = await getToken();

    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Debe iniciar sesion")));
      return;
    }

    String resp = "{}";
    Map<String, String> parametros = {"device": 'app', "token": token};
    var result = await http.post(Uri.parse(CARRITO_LIST), body: parametros);
    if (result.statusCode == 200) {
      resp = result.body;
    }
    Map m = json.decode(resp);
    setState(() {
      total = m["total"];
      carrito = m["detalle"];
      ventid = m["ventid"];
    });
  }

  Future<void> eliminarProd(String prod) async {
    String? token = await getToken();

    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Debe iniciar sesion")));
      return;
    }

    String resp = "{}";
    Map<String, String> parametros = {
      "device": 'app',
      "token": token,
      'prod': prod
    };
    var result = await http.post(Uri.parse(CARRITO_DEL), body: parametros);
    if (result.statusCode == 200) {
      resp = result.body;
    }
    Map m = json.decode(resp);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m["mensaje"])));
    if (m["success"]) {
      getReq();
    }
  }

  Future<void> cancelarCompra() async {
    String? token = await getToken();

    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Debe iniciar sesion")));
      return;
    }

    String resp = "{}";
    Map<String, String> parametros = {
      "device": 'app',
      "token": token,
      'codigo': ventid
    };
    var result = await http.post(Uri.parse(CARRITO_CANCEL), body: parametros);
    if (result.statusCode == 200) {
      resp = result.body;
    }
    Map m = json.decode(resp);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m["mensaje"])));
    if (m["success"]) {
      getReq();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (carrito.isNotEmpty)
                  ? Column(
                      children: [
                        Container(
                          constraints: const BoxConstraints(minHeight: 50),
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: carrito.length,
                            itemBuilder: (context, index) {
                              Map elem = carrito[index];
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
                                              fit: BoxFit.cover,
                                              "$URL_CARRITO${elem["img"]}}")),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                      Expanded(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                              style: primaryButton,
                                              onPressed: () {
                                                eliminarProd(elem["id"]);
                                              },
                                              icon: primaryIconButton(
                                                  Icons.delete))
                                        ],
                                      ))
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Card(
                          color: cardBackground,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: Row(
                              children: [
                                const Text(
                                  "Total: ",
                                  style: styleBold_2,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Monto(monto: total)
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                  style: secondaryButton,
                                  icon: secondaryIconButton(
                                      Icons.remove_shopping_cart),
                                  onPressed: () {
                                    cancelarCompra();
                                  },
                                  label: Text(
                                    "Cancelar compra",
                                    style: secondaryButtonText,
                                  )),
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton.icon(
                                  style: primaryButton,
                                  icon: primaryIconButton(
                                      Icons.shopping_cart_checkout),
                                  onPressed: () {
                                    DefaultTabController.of(context)
                                        .animateTo(1);
                                  },
                                  label: Text(
                                    "Confirmar compra",
                                    style: primaryButtonText,
                                  ))
                            ],
                          ),
                        )
                      ],
                    )
                  : const Text("Su carrito esta vacio"),
            ],
          ),
        )
      ],
    );
  }
}

class Monto extends StatelessWidget {
  const Monto({super.key, required this.monto});

  final String monto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.currency_bitcoin,
          size: 15,
        ),
        Text(monto)
      ],
    );
  }
}

class TabDatos extends StatelessWidget {
  const TabDatos({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Datos de Facturacion",
              style: styleBoldB_2,
            ),
            const SizedBox(
              height: 20,
            ),
            Form(
                key: _formkey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: validar,
                      controller: razonSocial,
                      decoration:
                          inputStyle("Nombre o Razon Social", Icons.person),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      validator: validarRuc,
                      controller: ciruc,
                      decoration: inputStyle("CI o RUC", Icons.fingerprint),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      validator: validarTelefono,
                      controller: telefono,
                      decoration: inputStyle("Telefono", Icons.phone),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      validator: validarEmail,
                      controller: email,
                      decoration: inputStyle("Email", Icons.email),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      validator: validar,
                      controller: direccion,
                      decoration: inputStyle("Direccion", Icons.house),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                      style: secondaryButton,
                      icon: secondaryIconButton(Icons.arrow_back),
                      onPressed: () {
                        DefaultTabController.of(context).animateTo(0);
                      },
                      label: Text(
                        "Atras",
                        style: secondaryButtonText,
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton.icon(
                      style: primaryButton,
                      icon: primaryIconButton(Icons.arrow_forward),
                      onPressed: () {
                        if (!_formkey.currentState!.validate()) {
                          return;
                        }
                        final model =
                            Provider.of<ModelCarrito>(context, listen: false);
                        Map<String, String> campos = {
                          'nombre': razonSocial.text,
                          'ruc': ciruc.text,
                          'telefono': telefono.text,
                          'direccion': direccion.text,
                          'email': email.text
                        };
                        model.agregarCampos(campos);
                        DefaultTabController.of(context).animateTo(2);
                      },
                      label: Text(
                        "Siguiente",
                        style: primaryButtonText,
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TabUbicacion extends StatefulWidget {
  const TabUbicacion({super.key});

  @override
  State<TabUbicacion> createState() => _TabUbicacion();
}

class _TabUbicacion extends State<TabUbicacion> {
  MapController _mapController = MapController();

  getCurrentLocation() async {
    final model = Provider.of<ModelCarrito>(context, listen: false);
    log(model.datos.toString());
    if (model.datos.containsKey("lat")) {
      setState(() {
        //_center = LatLng(_locationData.latitude, _locationData.longitude);
        _mapController.move(
            LatLng(double.parse(model.datos["lat"]),
                double.parse(model.datos["lng"])),
            12);
      });
      return;
    }

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      actLugar(ubicacion);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        actLugar(ubicacion);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      actLugar(ubicacion);
      return;
    }
    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _mapController.move(LatLng(position.latitude, position.longitude), 13.0);
    });
  }

  List<Marker> marks = [];
  LatLng ubicacion = const LatLng(-25.2865, -57.6470);

  void actLugar(LatLng center) {
    Marker marker = Marker(
      point: center,
      child: Icon(
        Icons.location_on,
        color: primaryColor,
        size: 50,
      ), // center of 't Gooi
    );
    setState(() {
      ubicacion = center;
      if (marks.isEmpty) {
        marks.add(marker);
      } else {
        marks[0] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: ubicacion,
                onMapReady: getCurrentLocation,
                initialZoom: 12,
                onPositionChanged: (camera, hasGesture) {
                  actLugar(camera.center);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                RichAttributionWidget(
                  // Include a stylish prebuilt attribution widget that meets all requirments
                  attributions: [
                    TextSourceAttribution('OpenStreetMap',
                        onTap: () {}), // (external)
                    // Also add images...
                  ],
                ),
                MarkerLayer(markers: marks)
              ],
            ),
            Positioned(
              top: 15,
              left: 15,
              child: Badge(
                backgroundColor: primaryColor,
                label: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Ubicacion de entrega"),
                ),
              ),
            ),
            Positioned(
                bottom: 50,
                left: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: secondaryIconButton(Icons.arrow_back),
                      onPressed: () {
                        DefaultTabController.of(context).animateTo(1);
                      },
                      label: Text(
                        "ANTERIOR",
                        style: secondaryButtonText,
                      ),
                      style: secondaryButton,
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    ElevatedButton.icon(
                      icon: primaryIconButton(Icons.arrow_forward),
                      onPressed: () {
                        Map<String, String> campos = {
                          "lat":
                              _mapController.camera.center.latitude.toString(),
                          "lng":
                              _mapController.camera.center.longitude.toString()
                        };
                        final model =
                            Provider.of<ModelCarrito>(context, listen: false);
                        model.agregarCampos(campos);
                        DefaultTabController.of(context).animateTo(3);
                      },
                      label: Text(
                        "SIGUIENTE",
                        style: primaryButtonText,
                      ),
                      style: primaryButton,
                    ),
                  ],
                ))
          ],
        ));
  }
}

class TabPagar extends StatelessWidget {
  const TabPagar({super.key});

  Future<void> pagar(Map info, BuildContext ctx) async {
    //DefaultTabController.of(ctx).animateTo(5);
    //return;

    Map mipost = info;

    mipost["token"] = await getToken();

    mipost["device"] = "app";

    log("aaaaaaaaaaaaaaaaaaaa");

    var respuesta = await http.post(Uri.parse(CARRITO_PAGAR), body: mipost);

    log(respuesta.body);

    try {
      Map jsn = json.decode(respuesta.body);
      if (jsn["success"] == true) {
        log(jsn["mensaje"]);
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
            content: Text("Ocurrio un error durante el pago Cod: 1")));
      }
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content: Text("Ocurrio un error durante el pago. Cod: 2")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Text(
                "Finalizar Compra",
                style: styleBold,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "¿Desea pagar ahora?",
                style: styleNormal,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 35,
        ),
        ElevatedButton.icon(
          style: primaryButton,
          onPressed: () {
            final model = Provider.of<ModelCarrito>(context, listen: false);
            pagar(model.datos, context);
          },
          label: Text(
            "Pagar",
            style: primaryButtonText,
          ),
          icon: primaryIconButton(Icons.payments_outlined),
        ),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton.icon(
          style: secondaryButton,
          onPressed: () {
            DefaultTabController.of(context).animateTo(2);
          },
          label: Text(
            "Anterior",
            style: secondaryButtonText,
          ),
          icon: secondaryIconButton(Icons.arrow_back),
        )
      ],
    );
  }
}
