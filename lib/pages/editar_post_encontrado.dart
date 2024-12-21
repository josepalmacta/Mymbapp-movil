import 'dart:convert';
import 'dart:math' as math;
import 'package:mymbapp/data/endpoints.dart';
import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/pages/cuenta_page.dart';
import 'package:mymbapp/pages/home_page.dart';
import 'package:mymbapp/pages/post_encontrado_page.dart';
import 'package:mymbapp/utilidades/metodos.dart';
import 'package:mymbapp/utilidades/sesionToken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

class MyModel with ChangeNotifier {
  List<Map> myList = [];
  Map post = {};

  String postid = "0";

  void eliminarMascota(int index) {
    myList.removeAt(index);
    notifyListeners();
  }

  void pasarImagenes(Map imas) {
    myList.add(imas);
    log("Imagen agregada, notificando...");
    //notifyListeners();
  }

  void agregarCampos(Map campos) {
    campos.forEach((key, value) {
      post[key] = value;
    });
    //notifyListeners();
  }

  void setPostId(String id) {
    postid = id;
    //notifyListeners();
  }

  void eliminarCampos(Map<String, String> campos) {
    campos.forEach((key, value) {
      post.remove(key);
    });
    notifyListeners();
  }
}

final nombre_controller = TextEditingController();
final descripcion_controller = TextEditingController();
final contacto_controller = TextEditingController();
final recompensa_controller = TextEditingController();
final info_controller = TextEditingController();

final _formkey = GlobalKey<FormState>();
final _formkey2 = GlobalKey<FormState>();

class EditarPostEncontradoPage extends StatefulWidget {
  const EditarPostEncontradoPage({super.key, required this.pid});
  final String pid;
  @override
  State<EditarPostEncontradoPage> createState() =>
      _EditarPostEncontradoPageState();
}

class _EditarPostEncontradoPageState extends State<EditarPostEncontradoPage> {
  List<Map> datos = [];
  Future<bool> checkLogin() async {
    String? tkn = await getToken();
    if (tkn == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Debe iniciar sesion")));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => CuentaPage()));
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyModel(),
      child: DefaultTabController(
          length: 5,
          child: Scaffold(
              appBar: AppBar(
                title: const Text("Actualizar Publicacion"),
              ),
              body: MyTabs(pid: widget.pid))),
    );
  }
}

class MyTabs extends StatefulWidget {
  const MyTabs({super.key, required this.pid});

  final String pid;

  @override
  State<MyTabs> createState() => _MyTabsState();
}

class _MyTabsState extends State<MyTabs> {
  @override
  Widget build(BuildContext context) {
    return TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        children: [Tab_1(pid: widget.pid), Tab_4(), Tab_3(), Tab_5(), Tab_6()]);
  }
}

class Tab_1 extends StatefulWidget {
  const Tab_1({super.key, required this.pid});
  final String pid;
  @override
  State<Tab_1> createState() => _Tab_1State();
}

class _Tab_1State extends State<Tab_1> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
        future: getReq(widget.pid, context),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error.toString());
            return Text(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            return T1body(
              r: snapshot.data!,
              pid: widget.pid,
            );
          } else {
            return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: const Center(child: CircularProgressIndicator()));
          }
        });
  }
}

class T1body extends StatefulWidget {
  const T1body({super.key, required this.pid, required this.r});
  final String pid;
  final Map r;
  @override
  State<T1body> createState() => _T1bodyState();
}

class _T1bodyState extends State<T1body> {
  Widget cardz() {
    final model = Provider.of<MyModel>(context, listen: false);
    model.agregarCampos(widget.r);
    model.setPostId(widget.pid);
    if (widget.r["mascotas"] != null) {
      List l = widget.r["mascotas"];
      for (var element in l) {
        model.pasarImagenes(element);
      }
    }
    return CardsMascotas();
  }

  Future<void> finalizarPost(String postid, BuildContext ctx) async {
    String? token = await getToken();

    Map<String, String> mipost = {
      'device': 'app',
      'token': token!,
      'post': postid
    };

    log("aaaaaaaaaaaaaaaaaaaa");
    log(mipost.toString());

    var respuesta = await http.post(Uri.parse(ENCONTRADOS_FIN), body: mipost);

    try {
      Map jsn = json.decode(respuesta.body);
      if (jsn["success"] == true) {
        //DefaultTabController.of(ctx).animateTo(4);
        ScaffoldMessenger.of(ctx)
            .showSnackBar(SnackBar(content: Text(jsn["mensaje"])));
        Navigator.pushReplacement(
            ctx, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
            content: Text("Ocurrio un error durante la publicacion cod:1")));
      }
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content: Text("Ocurrio un error durante la publicacion cod:2")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            "¿Ya localizo al propietario?.",
            style: styleBold,
          ),
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Text(
              "Si logro localizar al propietario por favor haga clic en el boton para actualizar el estado de la publicacion a LOCALIZADO",
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton.icon(
              style: primaryButton,
              icon: primaryIconButton(Icons.check),
              onPressed: () {
                //_showAlertDialog(context);
                finalizarPost(widget.pid, context);
              },
              label: Text(
                "Mascota Encontrada",
                style: primaryButtonText,
              )),
          Padding(padding: const EdgeInsets.all(15), child: cardz()),
          const BtnSgte()
        ],
      ),
    );
  }
}

Future<Map> getReq(String a, BuildContext context) async {
  String? token = await getToken();
  if (token == null) {
    return {};
  }
  final model = Provider.of<MyModel>(context, listen: false);
  if (model.myList.isNotEmpty) {
    return {};
  }
  String resp = "[]";
  Map<String, String> JsonBody = {'post': a, 'device': 'app', 'token': token};
  var result = await http.post(Uri.parse(ENCONTRADOS_SHOW), body: JsonBody);
  if (result.statusCode == 200) {
    // If you are sure that your web service has json string, return it directly
    resp = result.body;
  }
  log("holaaaaaaaaaaa");
  return json.decode(resp);
}

class Tab_5 extends StatelessWidget {
  const Tab_5({super.key});

  Future<void> crearPost(Map info, String postid, BuildContext ctx) async {
    //DefaultTabController.of(ctx).animateTo(5);
    //return;

    log(info.toString());

    String? token = await getToken();

    Map<String, String> mipost = {
      'device': 'app',
      'token': token!,
      'info': info["info"],
      'contacto': info["contacto"],
      'lat': info["lat"],
      'long': info["lng"],
      'post': postid
    };

    log("aaaaaaaaaaaaaaaaaaaa");
    log(mipost.toString());

    var respuesta = await http.post(Uri.parse(ENCONTRADOS_EDIT), body: mipost);

    try {
      Map jsn = json.decode(respuesta.body);
      if (jsn["success"] == true) {
        DefaultTabController.of(ctx).animateTo(4);
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
            content: Text("Ocurrio un error durante la publicacion 1")));
      }
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content: Text("Ocurrio un error durante la publicacion 2")));
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
                "Ya tenemos la informacion necesaria",
                style: styleBold,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "¿Desea actualizar la publicacion ahora?",
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
            final model = Provider.of<MyModel>(context, listen: false);
            crearPost(model.post, model.postid, context);
          },
          label: Text(
            "ACTUALIZAR PUBLICACION",
            style: primaryButtonText,
          ),
          icon: primaryIconButton(Icons.post_add),
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

class Tab_6 extends StatelessWidget {
  const Tab_6({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Image.asset("assets/img/revision.jpg"),
          const SizedBox(
            height: 15,
          ),
          const Text(
            "Publicacion Actualizada",
            style: styleBold,
          ),
          const SizedBox(
            height: 15,
          ),
          const SizedBox(
              height: 100,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "Su publicacion ha sido actualizada correctamente",
                  style: styleNormal,
                  textAlign: TextAlign.center,
                ),
              )),
          ElevatedButton.icon(
              onPressed: () {
                final model = Provider.of<MyModel>(context, listen: false);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PostEncontradoPage(
                              postid: model.postid,
                            )));
              },
              icon: primaryIconButton(Icons.file_copy),
              style: primaryButton,
              label: Text(
                "Ver Publicacion",
                style: primaryButtonText,
              ))
        ],
      ),
    );
  }
}

class Tab_4 extends StatefulWidget {
  const Tab_4({super.key});

  @override
  State<Tab_4> createState() => _Tab_4State();
}

class _Tab_4State extends State<Tab_4> {
  @override
  void initState() {
    super.initState();
    final model = Provider.of<MyModel>(context, listen: false);
    setState(() {
      contacto_controller.value =
          TextEditingValue(text: model.post["contacto"]);
      info_controller.value = TextEditingValue(text: model.post["info"]);
    });
  }

  crearPost() {
    final model = Provider.of<MyModel>(context, listen: false);
    Map<String, String> campos = {
      "contacto": contacto_controller.text,
      "info": info_controller.text
    };

    model.agregarCampos(campos);
    DefaultTabController.of(context).animateTo(2);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formkey2,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    validator: validar,
                    controller: contacto_controller,
                    decoration: inputStyle("Telefono de contacto", Icons.phone),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                        Text("Ingrese informacion que pueda ser de utilidad:"),
                  ),
                  SizedBox(
                    height: 150,
                    child: TextFormField(
                      maxLines: 10,
                      minLines: 5,
                      validator: validar,
                      controller: info_controller,
                      decoration: inputStyle("", Icons.info),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                      icon: secondaryIconButton(Icons.arrow_back),
                      style: secondaryButton,
                      onPressed: () {
                        DefaultTabController.of(context).animateTo(0);
                      },
                      label: Text(
                        "ANTERIOR",
                        style: secondaryButtonText,
                      )),
                  const SizedBox(
                    width: 25,
                  ),
                  ElevatedButton.icon(
                      icon: primaryIconButton(Icons.arrow_forward),
                      style: primaryButton,
                      onPressed: () {
                        if (_formkey2.currentState!.validate()) {
                          crearPost();
                        }
                      },
                      label: Text(
                        "SIGUIENTE",
                        style: primaryButtonText,
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Tab_3 extends StatefulWidget {
  const Tab_3({super.key});

  @override
  State<Tab_3> createState() => _Tab_3State();
}

class _Tab_3State extends State<Tab_3> {
  MapController _mapController = MapController();

  getCurrentLocation() async {
    final model = Provider.of<MyModel>(context, listen: false);
    log(model.post.toString());
    if (model.post.containsKey("lat")) {
      setState(() {
        //_center = LatLng(_locationData.latitude, _locationData.longitude);
        _mapController.move(
            LatLng(double.parse(model.post["lat"]),
                double.parse(model.post["lng"])),
            12);
      });
      return;
    }

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      actCirculo(ubicacion);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        actCirculo(ubicacion);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      actCirculo(ubicacion);
      return;
    }
    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _mapController.move(LatLng(position.latitude, position.longitude), 13.0);
    });
  }

  List<CircleMarker> circulos = [];
  LatLng ubicacion = const LatLng(-25.2865, -57.6470);

  void actCirculo(LatLng center) {
    CircleMarker marker = CircleMarker(
      point: center, // center of 't Gooi
      radius: 2000,
      useRadiusInMeter: true,
      color: primaryColor.withOpacity(0.3),
      borderColor: primaryColor.withOpacity(0.7),
      borderStrokeWidth: 2,
    );
    setState(() {
      ubicacion = center;
      if (circulos.isEmpty) {
        circulos.add(marker);
      } else {
        circulos[0] = marker;
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
                  actCirculo(camera.center);
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
                CircleLayer(circles: circulos)
              ],
            ),
            Positioned(
              top: 15,
              left: 15,
              child: Badge(
                backgroundColor: primaryColor,
                label: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Zona encontrada"),
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
                        "lat": _mapController.camera.center.latitude.toString(),
                        "lng": _mapController.camera.center.longitude.toString()
                      };
                      final model =
                          Provider.of<MyModel>(context, listen: false);
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
              ),
            )
          ],
        ));
  }
}

class BtnSgte extends StatefulWidget {
  const BtnSgte({
    super.key,
  });

  @override
  State<BtnSgte> createState() => BtnSgteState();
}

class BtnSgteState extends State<BtnSgte> {
  int flag_0 = 0;
  @override
  Widget build(BuildContext context) {
    return Consumer<MyModel>(builder: (context, model, child) {
      return (model.myList.isEmpty)
          ? const SizedBox(
              height: 1,
            )
          : ElevatedButton.icon(
              icon: primaryIconButton(Icons.arrow_forward),
              onPressed: () {
                DefaultTabController.of(context).animateTo(1);
              },
              label: Text(
                "SIGUIENTE",
                style: primaryButtonText,
              ),
              style: primaryButton,
            );
    });
  }

  void actualizar() {
    setState(() {
      flag_0 = math.Random().nextInt(10);
    });
  }
}

class CardsMascotas extends StatefulWidget {
  const CardsMascotas({super.key});

  @override
  State<CardsMascotas> createState() => CardsMascotasState();
}

class CardsMascotasState extends State<CardsMascotas> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyModel>(builder: (context, model, child) {
      log("Consumer rebuild triggered");
      return Column(
        children: cargarCards(model.myList),
      );
    });
  }

  List<Widget> cargarCards(List<Map> imagenes) {
    List<Widget> lista = [];
    log("holaaa");
    for (var j = 0; j < imagenes.length; j++) {
      List<Widget> ims = [];
      for (var i = 0; i < imagenes[j]["imgs"].length; i++) {
        ims.add(
          SizedBox(
            width: 70,
            height: 70,
            child: Image.network(
              "$ENCONTRADOS_IMG/${imagenes[j]["imgs"][i]}",
              fit: BoxFit.cover,
            ),
          ),
        );
      }
      lista.add(CardResumen(
        descripcion: imagenes[j]["descripcion"],
        ims: ims,
        j: j,
      ));
    }
    return lista;
  }
}

class CardResumen extends StatelessWidget {
  const CardResumen(
      {super.key,
      required this.descripcion,
      required this.ims,
      required this.j});

  final String descripcion;
  final List<Widget> ims;
  final int j;

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MyModel>(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mascota encontrada",
              style: styleBold,
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  "Descripcion: ",
                  style: styleBold,
                ),
                ConstrainedBox(
                    constraints: const BoxConstraints(
                        minHeight: 20, maxWidth: double.maxFinite),
                    child: Text(descripcion)),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Imagenes",
              style: styleBold,
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 80,
              child: GridView.extent(
                physics: const NeverScrollableScrollPhysics(),
                maxCrossAxisExtent: 70,
                crossAxisSpacing: 5,
                children: ims,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton.filled(
                  onPressed: () {
                    model.eliminarMascota(j);
                  },
                  icon: const Icon(Icons.delete),
                  style: primaryButton,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
