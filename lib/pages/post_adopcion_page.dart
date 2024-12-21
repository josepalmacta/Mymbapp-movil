import 'dart:convert';

import 'package:mymbapp/data/endpoints.dart';
import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/widgets/autor_post.dart';
import 'package:mymbapp/widgets/customcarousel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class PostAdopcionPage extends StatefulWidget {
  const PostAdopcionPage({super.key, required this.postid});
  final String postid;
  @override
  State<PostAdopcionPage> createState() => _PostAdopcionPageState();
}

class _PostAdopcionPageState extends State<PostAdopcionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("En adopcion"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                  future: fetchPosts(widget.postid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return PostBody(
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

  Future<Map> fetchPosts(String a) async {
    return await compute(getReq, a);
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
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getBadge(jsn["p_estado"]),
              const SizedBox(
                height: 10,
              ),
              Container(
                constraints: const BoxConstraints(minHeight: 20),
                child: Text(
                  "En adopcion en " + jsn["lugar"],
                  style: styleBold,
                ),
              ),
            ],
          ),
        ),
        CarouselExample(jsn: jsn["mascotas"], tipo: "a"),
        Column(
          children: getDetalles(jsn["mascotas"]),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            child: Card(
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
                          "Requisitos para adopcion",
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      constraints: const BoxConstraints(minHeight: 40),
                      child: Text(jsn["info"]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: SizedBox(
              height: 300,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Stack(children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                          double.parse(jsn["lat"]), double.parse(jsn["lng"])),
                      initialZoom: 12,
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
                      CircleLayer(
                          circles: getCirc(LatLng(double.parse(jsn["lat"]),
                              double.parse(jsn["lng"]))))
                    ],
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Badge(
                      backgroundColor: primaryColor,
                      label: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text("Ubicacion"),
                      ),
                    ),
                  )
                ]),
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: cardContacto(
              persona: jsn["nombre"],
              numero: jsn["contacto"],
              per_ciu: jsn["per_ciudad"],
              img: "$USER_IMG/${jsn["per_imagen"]}",
              postid: jsn["postid"],
              tipo: "adopcion"),
        )
      ],
    );
  }

  List<CircleMarker> getCirc(LatLng center) {
    List<CircleMarker> l = [];
    CircleMarker marker = CircleMarker(
      point: center, // center of 't Gooi
      radius: 2000,
      useRadiusInMeter: true,
      color: primaryColor.withOpacity(0.3),
      borderColor: primaryColor.withOpacity(0.7),
      borderStrokeWidth: 2,
    );
    l.add(marker);
    return l;
  }
}

class detalle_text extends StatelessWidget {
  const detalle_text(
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

class descripcion_text extends StatelessWidget {
  const descripcion_text({
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

class detalle_grupo extends StatelessWidget {
  const detalle_grupo({super.key, required this.obj});
  final Map obj;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          detalle_text(
              titulo1: "Especie",
              texto1: obj["especie"],
              titulo2: "Raza",
              texto2: obj["raza"]),
          descripcion_text(titulo: "Descripcion", texto: obj["descripcion"]),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}

List<Widget> getDetalles(List lst) {
  List<Widget> lista = [];

  for (var element in lst) {
    lista.add(Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
          color: cardBackground,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: detalle_grupo(obj: element),
          )),
    ));
  }

  return lista;
}

Widget getBadge(String estado) {
  if (estado == "ADOPTADO") {
    return Badge(
      backgroundColor: Colors.red[400],
      label: const Padding(
        padding: EdgeInsets.all(5),
        child: Text("ADOPTADO"),
      ),
    );
  }
  return const SizedBox(
    height: 1,
  );
}

Future<Map> getReq(String a) async {
  String resp = "[]";
  Map<String, String> JsonBody = {
    'post': a,
  };
  var result = await http.post(Uri.parse(ADOPCION_SHOW), body: JsonBody);
  if (result.statusCode == 200) {
    // If you are sure that your web service has json string, return it directly
    resp = result.body;
  }
  //log(resp);
  return json.decode(resp);
}
