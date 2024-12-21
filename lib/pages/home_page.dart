import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:mymbapp/data/endpoints.dart';
import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/data/globals.dart';
import 'package:mymbapp/pages/post_adopcion_page.dart';
import 'package:mymbapp/pages/post_encontrado_page.dart';
import 'package:mymbapp/pages/post_perdido_page.dart';
import 'package:mymbapp/pages/posts_adopcion_page.dart';
import 'package:mymbapp/pages/posts_encontrados_page.dart';
import 'package:mymbapp/pages/posts_perdidos_page.dart';
import 'package:mymbapp/widgets/appbar_logout.dart';
import 'package:mymbapp/widgets/card_adopcion.dart';
import 'package:mymbapp/widgets/card_encontrados.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mymbapp/widgets/card_1.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:developer';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppbarLogout(),
        drawer: FutureBuilder<Widget>(
          future: buildDrawerHeader(),
          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Muestra un indicador de carga mientras se obtiene el widget
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Muestra un mensaje de error si ocurre un problema
              return Center(child: Text('Ocurrió un error'));
            } else if (snapshot.hasData) {
              // Devuelve el widget construido
              return snapshot.data!;
            } else {
              // Si no hay datos, muestra un widget vacío
              return Center(child: Text('Sin datos'));
            }
          },
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              MapaInteractivo(),
              const SizedBox(
                height: 30,
              ),
              ultimosPosts(
                  tipos: "mperdidos",
                  titulo: "Mascotas Perdidas",
                  aspectRatio: 0.58,
                  maxCrossAxisExtent: 200),
              const SizedBox(
                height: 30,
              ),
              ultimosPosts(
                  tipos: "mencontrados",
                  titulo: "Mascotas Encontradas",
                  aspectRatio: 0.70,
                  maxCrossAxisExtent: 200),
              const SizedBox(
                height: 30,
              ),
              ultimosPosts(
                  tipos: "madopciones",
                  titulo: "Mascotas en Adopcion",
                  aspectRatio: 0.62,
                  maxCrossAxisExtent: 200),
            ],
          ),
        ));
  }

  double _calculateGridHeight(int itemCount, double aspectRatio) {
    int crossAxisCount = (MediaQuery.of(context).size.width / 200.0).floor();
    int rowCount = (itemCount / crossAxisCount).ceil();
    double rowHeight = (200.0 / aspectRatio) + 5.0;
    return rowHeight * rowCount;
  }
}

class ultimosPosts extends StatelessWidget {
  final String tipos;
  final String titulo;
  final double aspectRatio;
  final double maxCrossAxisExtent;

  ultimosPosts({
    required this.tipos,
    required this.titulo,
    required this.aspectRatio,
    required this.maxCrossAxisExtent,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: fetchPosts(tipos),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          log("================================");
          log(snapshot.error.toString());
          log("================================");
        }
        if (snapshot.hasData) {
          return Column(
            children: [
              verMas(titulo: titulo, tipo: tipos),
              SizedBox(
                height: _calculateGridHeight(
                    context, snapshot.data.length, aspectRatio),
                child: GridView.extent(
                  physics: const NeverScrollableScrollPhysics(),
                  maxCrossAxisExtent: maxCrossAxisExtent,
                  padding: const EdgeInsets.all(5.0),
                  mainAxisSpacing: 5.0,
                  crossAxisSpacing: 5.0,
                  childAspectRatio: aspectRatio,
                  children: snapshot.data,
                ),
              ),
            ],
          );
        } else {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
      },
    );
  }

  double _calculateGridHeight(
      BuildContext context, int itemCount, double aspectRatio) {
    int crossAxisCount =
        (MediaQuery.of(context).size.width / maxCrossAxisExtent).floor();
    int rowCount = (itemCount / crossAxisCount).ceil();
    double rowHeight =
        (maxCrossAxisExtent / aspectRatio) + 5.0; // Adding 5 for spacing
    return rowHeight * rowCount;
  }

  Future<List> fetchPosts(String posts) async {
    if (posts == "mperdidos") {
      return _cards_load(await compute(getReq, posts));
    }
    if (posts == "mencontrados") {
      return loadEncontrados(await compute(getReq, posts));
    }
    return loadAdopciones(await compute(getReq, posts));
  }

  List<Widget> _cards_load(List jsn) {
    List<Widget> lista = [];

    int i = 0;
    for (var elem in jsn) {
      lista.add(CardP(
          postid: elem["postid"],
          nombres: elem["nombres"],
          lugar: elem["lugar"],
          tipo: elem["especie"],
          estado: elem["estado"],
          recompensa: elem["recompensa"],
          imagen: "$PERDIDOS_IMG/${elem["img"]}",
          indice: i.toString()));
      i++;
    }

    return lista;
  }

  List<Widget> loadEncontrados(List jsn) {
    List<Widget> lista = [];

    int i = 0;
    for (var elem in jsn) {
      lista.add(CardE(
          postid: elem["postid"],
          lugar: elem["lugar"],
          estado: elem["estado"],
          imagen: "$ENCONTRADOS_IMG/${elem["img"]}",
          indice: i.toString()));
      i++;
    }

    return lista;
  }

  List<Widget> loadAdopciones(List jsn) {
    List<Widget> lista = [];

    int i = 0;
    for (var elem in jsn) {
      lista.add(CardA(
          postid: elem["postid"],
          genero: elem["genero"],
          tipo: elem["especie"],
          estado: elem["estado"],
          imagen: "$ADOPCION_IMG/${elem["img"]}",
          indice: i.toString()));
      i++;
    }

    return lista;
  }
}

class verMas extends StatelessWidget {
  const verMas({super.key, required this.titulo, required this.tipo});

  final String titulo;
  final String tipo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(10), child: Text(titulo))),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Widget destino = PostsPerdidosPage();
                    if (tipo == "mencontrados") {
                      destino = PostsEncontradosPage();
                    }
                    if (tipo == "madopciones") {
                      destino = PostsAdopcionPage();
                    }
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => destino));
                  },
                  child: const Row(
                    children: [
                      Text("Ver mas"),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 15,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

Future<List> getReq(String posts) async {
  String resp = "[]";
  var result = await http.post(Uri.parse("$URL_BUSQUEDA/$posts"));
  if (result.statusCode == 200) {
    // If you are sure that your web service has json string, return it directly
    resp = result.body;
  }
  return json.decode(resp);
}

class MapaInteractivo extends StatefulWidget {
  const MapaInteractivo({super.key});

  @override
  State<MapaInteractivo> createState() => _MapaInteractivoState();
}

class _MapaInteractivoState extends State<MapaInteractivo> {
  MapController _mapController = MapController();
  LatLng ubicacion = const LatLng(-25.2865, -57.6470);

  getCurrentLocation() async {
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

  void actLugar(LatLng center) {
    setState(() {
      ubicacion = center;
    });
  }

  List<Marker> markers = [];

  bool cargando = false;

  Future<void> cargarMarkers(LatLng ubi) async {
    if (cargando) {
      return;
    }
    cargando = true;
    var respuesta = await http.get(Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?lat=${ubi.latitude.toString()}&lon=${ubi.longitude.toString()}&zoom=12&addressdetails=1&format=json"));
    if (respuesta.statusCode == 200) {
      log("reqq");
      Map jsonResponse = json.decode(respuesta.body);
      String? ciudad = jsonResponse["address"]["city"];
      if (ciudad == null) {
        cargando = false;
        return;
      }
      var respuesta2 =
          await http.post(Uri.parse(MAPA_LIST), body: {'ciudad': ciudad});
      List res = json.decode(respuesta2.body);
      List<Marker> mks = [];
      for (var element in res) {
        mks.add(marcador(element, context));
      }
      setState(() {
        markers = mks;
      });
    }
    cargando = false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
          height: 500,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: ubicacion,
                  initialZoom: 12,
                  onPositionChanged: (camera, hasGesture) {
                    //log(camera.center);
                    cargarMarkers(camera.center);
                  },
                  onMapReady: getCurrentLocation,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  RichAttributionWidget(
                    // Include a stylish prebuilt attribution widget that meets all requirments
                    attributions: [
                      TextSourceAttribution('OpenStreetMap', onTap: () {}),
                      TextSourceAttribution('Leaflet',
                          onTap: () {}), // (external)
                      // Also add images...
                    ],
                  ),
                  MarkerLayer(markers: markers)
                ],
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Badge(
                  backgroundColor: primaryColor,
                  label: const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text("Mapa en tiempo real"),
                  ),
                ),
              )
            ]),
          )),
    );
  }
}

Marker marcador(Map obj, BuildContext ctx) {
  LatLng ubi = LatLng(double.parse(obj["lat"]), double.parse(obj["long"]));
  String titulo = "Mascota encontrada";
  Color colr = Colors.green[600]!;
  Widget page = PostEncontradoPage(postid: obj["postid"]);
  if (obj["tipo"] == "perdidos") {
    titulo = "Se busca a ${obj["nombres"]}";
    colr = primaryColor;
    page = PostPerdidoPage(postid: obj["postid"]);
  }
  if (obj["tipo"] == "adopcion") {
    titulo = "En adopcion";
    colr = Colors.red[600]!;
    page = PostAdopcionPage(postid: obj["postid"]);
  }
  return Marker(
      point: ubi,
      child: Tooltip(
        triggerMode: TooltipTriggerMode.tap,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        richMessage: WidgetSpan(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(titulo),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton.icon(
                  style: primaryButton,
                  icon: primaryIconButton(Icons.text_snippet),
                  onPressed: () {
                    navigatorKey.currentState?.push(
                      MaterialPageRoute(
                        builder: (context) => page,
                      ),
                    );
                  },
                  label: Text(
                    "Ver Post",
                    style: primaryButtonText,
                  ))
            ],
          ),
        )),
        child: CircleAvatar(
          backgroundColor: colr,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: CircleAvatar(
              backgroundColor: colr,
              backgroundImage: NetworkImage("$URL_GLOBAL${obj["img"]}"),
            ),
          ),
        ),
      ));
}
