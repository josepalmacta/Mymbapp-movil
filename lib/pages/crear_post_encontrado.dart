import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:developer';
import 'package:mymbapp/data/endpoints.dart';
import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/pages/cuenta_page.dart';
import 'package:mymbapp/pages/mis_publicaciones_page.dart';
import 'package:mymbapp/utilidades/metodos.dart';
import 'package:mymbapp/utilidades/sesionToken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:img_picker/img_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class MyModel with ChangeNotifier {
  List<Map> myList = [];
  Map post = {};

  void eliminarMascota(int index) {
    myList.removeAt(index);
    notifyListeners();
  }

  void pasarImagenes(Map imas) {
    myList.add(imas);
    log("Imagen agregada, notificando...");
    notifyListeners();
  }

  void agregarCampos(Map<String, String> campos) {
    campos.forEach((key, value) {
      post[key] = value;
    });
    notifyListeners();
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

class CrearPostEncontradoPage extends StatefulWidget {
  const CrearPostEncontradoPage({super.key});

  @override
  State<CrearPostEncontradoPage> createState() =>
      _CrearPostEncontradoPageState();
}

class _CrearPostEncontradoPageState extends State<CrearPostEncontradoPage> {
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
          length: 6,
          child: Scaffold(
              appBar: AppBar(
                title: const Text("Encontre una Mascota"),
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
        children: [Tab_1(), Tab_2(), Tab_3(), Tab_4(), Tab_5(), Tab_6()]);
  }
}

class Tab_1 extends StatefulWidget {
  const Tab_1({super.key});

  @override
  State<Tab_1> createState() => _Tab_1State();
}

class _Tab_1State extends State<Tab_1> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Agregue informacion sobre la mascota.",
            style: styleBold,
          ),
          const SizedBox(
            height: 20,
          ),
          const Text("Puede agregar mas de una mascota a la publicacion."),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton.icon(
              style: secondaryButton,
              icon: secondaryIconButton(Icons.library_add_outlined),
              onPressed: () {
                _showAlertDialog(context);
              },
              label: Text(
                "Agregar mascota",
                style: secondaryButtonText,
              )),
          const Padding(
            padding: const EdgeInsets.all(15),
            child: CardsMascotas(),
          ),
          const BtnSgte()
        ],
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    final model = Provider.of<MyModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangeNotifierProvider.value(
          value: model,
          child: DialogFrm(),
        );
      },
    );
  }
}

class Tab_2 extends StatefulWidget {
  const Tab_2({super.key});

  @override
  State<Tab_2> createState() => _Tab_2State();
}

class _Tab_2State extends State<Tab_2> {
  String? selDepartamento;
  String? selCiudad;
  String? selBarrio;
  List<Map<String, String>> departamentos = [];
  List<Map<String, String>> ciudades = [];
  List<Map<String, String>> barrios = [];

  @override
  void initState() {
    super.initState();
    cargarDepartamentos();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyModel>(builder: (context, value, child) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "¿En que barrio fue encontrado?",
              style: styleBold,
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                  child: Text("Departamento"),
                ),
                DropdownButtonFormField(
                  isExpanded: true,
                  decoration: DropDStyle("Departamento"),
                  items: departamentos.map<DropdownMenuItem<String>>(
                      (Map<String, String> item) {
                    return DropdownMenuItem<String>(
                      value: item["id"],
                      child: Text(item["nombre"]!),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    selDepartamento = newValue;
                    cargarCiudades();
                  },
                  value: selDepartamento,
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                  child: Text("Ciudad"),
                ),
                DropdownButtonFormField(
                  isExpanded: true,
                  decoration: DropDStyle("Ciudad"),
                  items: ciudades.map<DropdownMenuItem<String>>(
                      (Map<String, String> item) {
                    return DropdownMenuItem<String>(
                      value: item["id"],
                      child: Text(item["nombre"]!),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    selCiudad = newValue;
                    cargarBarrios();
                  },
                  value: selCiudad,
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                  child: Text("Barrio"),
                ),
                DropdownButtonFormField(
                  isExpanded: true,
                  decoration: DropDStyle("Barrio"),
                  items: barrios.map<DropdownMenuItem<String>>(
                      (Map<String, String> item) {
                    return DropdownMenuItem<String>(
                      value: item["id"],
                      child: Text(item["nombre"]!),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    selBarrio = newValue;
                  },
                  value: selBarrio,
                ),
              ],
            ),
            const SizedBox(
              height: 50,
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
                      Map<String, String> campos = {
                        "departamento": selDepartamento!,
                        "ciudad": selCiudad!,
                        "barrio": selBarrio!
                      };
                      value.agregarCampos(campos);
                      DefaultTabController.of(context).animateTo(2);
                    },
                    label: Text(
                      "SIGUIENTE",
                      style: primaryButtonText,
                    )),
              ],
            )
          ],
        ),
      );
    });
  }

  Future<void> cargarDepartamentos() async {
    final model = Provider.of<MyModel>(context, listen: false);
    var respuesta = await http.post(Uri.parse(DEPARTAMENTOS_LIST));
    if (respuesta.statusCode == 200) {
      log("reqq");
      List<dynamic> jsonResponse = json.decode(respuesta.body);
      setState(() {
        departamentos = jsonResponse.map((item) {
          return Map<String, String>.from(item);
        }).toList();
        selDepartamento = (model.post.containsKey("departamento"))
            ? model.post["departamento"]
            : departamentos[0]["id"];
        if (selCiudad == null) {
          cargarCiudades();
        }
      });
    }
  }

  Future<void> cargarCiudades() async {
    final model = Provider.of<MyModel>(context, listen: false);
    Map parametros = {"departamento": selDepartamento};
    var respuesta = await http.post(Uri.parse(CIUDADES_LIST), body: parametros);
    if (respuesta.statusCode == 200) {
      setState(() {
        List<dynamic> jsonResponse = json.decode(respuesta.body);
        ciudades = jsonResponse.map((item) {
          return Map<String, String>.from(item);
        }).toList();
        selCiudad = (model.post.containsKey("ciudad"))
            ? model.post["ciudad"]
            : ciudades[0]["id"];
        cargarBarrios();
      });
    }
  }

  Future<void> cargarBarrios() async {
    final model = Provider.of<MyModel>(context, listen: false);
    Map parametros = {"ciudad": selCiudad};
    var respuesta = await http.post(Uri.parse(BARRIOS_LIST), body: parametros);
    if (respuesta.statusCode == 200) {
      log(respuesta.body);
      setState(() {
        List<dynamic> jsonResponse = json.decode(respuesta.body);
        barrios = jsonResponse.map((item) {
          return Map<String, String>.from(item);
        }).toList();
        selBarrio = (model.post.containsKey("barrio"))
            ? model.post["barrio"]
            : barrios[0]["id"];
      });
    }
  }
}

class Tab_5 extends StatelessWidget {
  const Tab_5({super.key});

  Future<void> crearPost(Map info, List masco, BuildContext ctx) async {
    //DefaultTabController.of(ctx).animateTo(5);
    //return;

    Map mipost = {};
    mipost.addAll(info);
    List mascotas = [];
    mascotas.addAll(masco);
    for (var i = 0; i < mascotas.length; i++) {
      List lista = mascotas[i]["imgs"];
      for (var j = 0; j < lista.length; j++) {
        var bytes = await new File(lista[j]).readAsBytes();
        String base_64 = base64Encode(bytes);
        lista[j] = ",$base_64";
      }
      mascotas[i]["imgs"] = lista;
    }
    mipost["mascotas"] = mascotas;

    mipost["token"] = await getToken();

    mipost["device"] = "app";

    var body = json.encode(mipost);

    log("aaaaaaaaaaaaaaaaaaaa");

    var respuesta = await http.post(Uri.parse(ENCONTRADOS_ADD),
        headers: {"Content-Type": "application/json"}, body: body);

    try {
      Map jsn = json.decode(respuesta.body);
      if (jsn["success"] == true) {
        DefaultTabController.of(ctx).animateTo(5);
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
            content: Text("Ocurrio un error durante la publicacion")));
      }
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content: Text("Ocurrio un error durante la publicacion")));
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
                "¿Desea crear una publicacion ahora?",
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
            crearPost(model.post, model.myList, context);
          },
          label: Text(
            "CREAR PUBLICACION",
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
            DefaultTabController.of(context).animateTo(3);
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
            "Publicacion Creada",
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
                  "Su publicacion pasara por un proceso de revision manual antes de ser visible en la plataforma.",
                  style: styleNormal,
                  textAlign: TextAlign.center,
                ),
              )),
          ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MisPublicacionesPage()));
              },
              icon: primaryIconButton(Icons.file_copy),
              style: primaryButton,
              label: Text(
                "Mis Publicaciones",
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
  crearPost() {
    final model = Provider.of<MyModel>(context, listen: false);
    Map<String, String> campos = {
      "contacto": contacto_controller.text,
      "info": info_controller.text
    };

    model.agregarCampos(campos);
    DefaultTabController.of(context).animateTo(4);
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
                        DefaultTabController.of(context).animateTo(2);
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
                double.parse(model.post["long"])),
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
                        "long":
                            _mapController.camera.center.longitude.toString()
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

class MascotaForm extends StatefulWidget {
  MascotaForm({super.key});

  @override
  State<MascotaForm> createState() => _MascotaFormState();
}

class _MascotaFormState extends State<MascotaForm> {
  String? selEspecie;

  String? selRaza;

  String selGenero = "HEMBRA";

  List<Map<String, String>> especies = [];

  List<Map<String, String>> razas = [];

  @override
  void initState() {
    super.initState();
    cargarEspecies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
          key: _formkey,
          child: Column(
            children: [
              const Text(
                "Informacion de la mascota",
                style: styleBold,
              ),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    child: Text("Especie"),
                  ),
                  DropdownButtonFormField(
                    isExpanded: true,
                    decoration: DropDStyle("Especie"),
                    items: especies.map<DropdownMenuItem<String>>(
                        (Map<String, String> item) {
                      return DropdownMenuItem<String>(
                        value: item["id"],
                        child: Text(item["nombre"]!),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      selEspecie = newValue;
                      cargarRazas();
                    },
                    value: selEspecie,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    child: Text("Raza"),
                  ),
                  DropdownButtonFormField(
                    isExpanded: true,
                    decoration: DropDStyle("Raza"),
                    items: razas.map<DropdownMenuItem<String>>(
                        (Map<String, String> item) {
                      return DropdownMenuItem<String>(
                        value: item["id"],
                        child: Text(item["nombre"]!),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      selRaza = newValue;
                    },
                    value: selRaza,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    child: Text("Genero"),
                  ),
                  DropdownButtonFormField(
                    decoration: DropDStyle("Genero"),
                    items: const [
                      DropdownMenuItem(
                        value: "HEMBRA",
                        child: Text("HEMBRA"),
                      ),
                      DropdownMenuItem(
                        value: "MACHO",
                        child: Text("MACHO"),
                      )
                    ],
                    onChanged: (newValue) {
                      selGenero = newValue!;
                    },
                    value: selGenero,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: descripcion_controller,
                validator: validar,
                decoration: inputStyle("Descripcion", Icons.info),
              ),
            ],
          )),
    );
  }

  Future<void> cargarEspecies() async {
    var respuesta = await http.post(Uri.parse(ESPECIES_LIST));
    if (respuesta.statusCode == 200) {
      log("reqq");
      List<dynamic> jsonResponse = json.decode(respuesta.body);
      setState(() {
        especies = jsonResponse.map((item) {
          return Map<String, String>.from(item);
        }).toList();
        selEspecie = especies[0]["id"];
        if (selRaza == null) {
          cargarRazas();
        }
      });
    }
  }

  Future<void> cargarRazas() async {
    Map parametros = {"especie": selEspecie};

    var respuesta = await http.post(Uri.parse(RAZAS_LIST), body: parametros);
    if (respuesta.statusCode == 200) {
      log(respuesta.body);
      setState(() {
        List<dynamic> jsonResponse = json.decode(respuesta.body);
        razas = jsonResponse.map((item) {
          return Map<String, String>.from(item);
        }).toList();
        selRaza = razas[0]["id"];
      });
    }
  }
}

class DialogFrm extends StatefulWidget {
  const DialogFrm({super.key});

  @override
  State<DialogFrm> createState() => _DialogFrmState();
}

class _DialogFrmState extends State<DialogFrm> {
  List<String> imagenes = [];
  List<Widget> imags = [];
  final _dropdkey = GlobalKey<_MascotaFormState>();
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MyModel>(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      backgroundColor: Colors.white,
      child: Container(
        height: 800,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  MascotaForm(
                    key: _dropdkey,
                  ),
                  ElevatedButton.icon(
                      style: secondaryButton,
                      onPressed: (imagenes.length < 4)
                          ? () {
                              cargarImagen();
                            }
                          : null,
                      icon: secondaryIconButton(Icons.add_a_photo),
                      label: Text(
                        "Agregar imagenes",
                        style: secondaryButtonText,
                      )),
                ],
              ),
              SizedBox(
                  height: 130,
                  child: (imagenes.isEmpty)
                      ? const SizedBox(
                          height: 1,
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 100,
                              mainAxisSpacing: 5.0,
                              crossAxisSpacing: 5.0,
                            ),
                            itemCount: imagenes.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Stack(
                                children: [
                                  SizedBox(
                                    width: double.maxFinite,
                                    height: double.maxFinite,
                                    child: Image(
                                      image: FileImage(File(imagenes[index])),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  IconButton.filled(
                                    onPressed: () {
                                      borrarImagen(index);
                                    },
                                    icon: const Icon(Icons.delete),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        )),
              const SizedBox(
                height: 1,
              ),
              ElevatedButton.icon(
                style: primaryButton,
                onPressed: imagenes.isNotEmpty
                    ? () {
                        if (!_formkey.currentState!.validate()) {
                          return;
                        }
                        Map jsn = {
                          "descripcion": descripcion_controller.text,
                          "imgs": imagenes,
                          "especie": _dropdkey.currentState!.selEspecie,
                          "idraza": _dropdkey.currentState!.selRaza,
                          "genero": _dropdkey.currentState!.selGenero
                        };
                        model.pasarImagenes(jsn);
                        Navigator.of(context).pop();
                      }
                    : null,
                icon: primaryIconButton(Icons.playlist_add_check),
                label: Text("Aceptar", style: primaryButtonText),
              )
            ],
          ),
        ),
      ),
    );
  }

  void cargarImagen() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (photo != null) {
      setState(() {
        imagenes.add(photo.path);
      });
    }
  }

  void borrarImagen(int index) {
    setState(() {
      imagenes.removeAt(index);
    });
  }

  List<Widget> cargarImagenes(List imgs) {
    List<Widget> lista = [];
    for (var i = 0; i < imgs.length; i++) {
      lista.add(Stack(children: [
        Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Image(
            image: FileImage(File(imgs[i])),
            fit: BoxFit.cover,
          ),
        ),
        IconButton.filled(
          onPressed: () {
            borrarImagen(i);
          },
          icon: const Icon(Icons.delete),
          style: IconButton.styleFrom(
            backgroundColor: Colors.purple,
          ),
        )
      ]));
    }

    return lista;
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
        ims.add(SizedBox(
          width: 70,
          height: 70,
          child: Image(
            image: FileImage(File(imagenes[j]["imgs"][i])),
            fit: BoxFit.cover,
          ),
        ));
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
            ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 20),
                child: Row(
                  children: [
                    const Text(
                      "Descripcion: ",
                      style: styleBold,
                    ),
                    Text(descripcion),
                  ],
                )),
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
