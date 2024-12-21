import 'dart:convert';
import 'dart:developer';
import 'package:mymbapp/data/endpoints.dart';
import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/widgets/card_1.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostsPerdidosPage extends StatefulWidget {
  const PostsPerdidosPage({super.key});

  @override
  State<PostsPerdidosPage> createState() => _PostsPerdidosPageState();
}

class _PostsPerdidosPageState extends State<PostsPerdidosPage> {
  String? selEspecie = "-1";

  String? selRaza = "-1";

  String? pagina = "0";

  List<Map<String, String>> especies = [];

  List<Map<String, String>> razas = [];

  String? selDepartamento = "-1";
  String? selCiudad = "-1";
  String? selBarrio = "-1";
  List<Map<String, String>> departamentos = [];
  List<Map<String, String>> ciudades = [];
  List<Map<String, String>> barrios = [];

  List posts = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    getReq();
    cargarEspecies();
    cargarDepartamentos();
  }

  Future<void> cargarEspecies() async {
    var respuesta = await http.post(Uri.parse(ESPECIES_LIST));
    if (respuesta.statusCode == 200) {
      Map<String, String> a = {"id": "-1", "nombre": "SELECCIONAR"};
      List<Map<String, String>> b = [];
      b.add(a);
      json.decode(respuesta.body).forEach((item) {
        b.add(Map<String, String>.from(item));
      });
      setState(() {
        especies = b;
        selEspecie = especies[0]["id"];
        cargarRazas();
      });
    }
  }

  Future<void> cargarRazas() async {
    Map parametros = {"especie": selEspecie};

    var respuesta = await http.post(Uri.parse(RAZAS_LIST), body: parametros);
    if (respuesta.statusCode == 200) {
      Map<String, String> a = {"id": "-1", "nombre": "SELECCIONAR"};
      List<Map<String, String>> b = [];
      b.add(a);
      json.decode(respuesta.body).forEach((item) {
        b.add(Map<String, String>.from(item));
      });
      setState(() {
        razas = b;
        selRaza = razas[0]["id"];
      });
    }
  }

  Future<void> cargarDepartamentos() async {
    var respuesta = await http.post(Uri.parse(DEPARTAMENTOS_LIST));
    if (respuesta.statusCode == 200) {
      log("reqq2");
      Map<String, String> a = {"id": "-1", "nombre": "SELECCIONAR"};
      List<Map<String, String>> b = [];
      b.add(a);
      json.decode(respuesta.body).forEach((item) {
        b.add(Map<String, String>.from(item));
      });
      setState(() {
        departamentos = b;
        selDepartamento = departamentos[0]["id"];

        cargarCiudades();
      });
    }
  }

  Future<void> cargarCiudades() async {
    Map parametros = {"departamento": selDepartamento};
    var respuesta = await http.post(Uri.parse(CIUDADES_LIST), body: parametros);
    if (respuesta.statusCode == 200) {
      Map<String, String> a = {"id": "-1", "nombre": "SELECCIONAR"};
      List<Map<String, String>> b = [];
      b.add(a);
      json.decode(respuesta.body).forEach((item) {
        b.add(Map<String, String>.from(item));
      });
      setState(() {
        ciudades = b;
        selCiudad = ciudades[0]["id"];
        cargarBarrios();
      });
    }
  }

  Future<void> cargarBarrios() async {
    Map parametros = {"ciudad": selCiudad};
    var respuesta = await http.post(Uri.parse(BARRIOS_LIST), body: parametros);
    if (respuesta.statusCode == 200) {
      Map<String, String> a = {"id": "-1", "nombre": "SELECCIONAR"};
      List<Map<String, String>> b = [];
      b.add(a);
      json.decode(respuesta.body).forEach((item) {
        b.add(Map<String, String>.from(item));
      });
      setState(() {
        barrios = b;
        selBarrio = barrios[0]["id"];
      });
    }
  }

  Future<void> getReq() async {
    String resp = "[]";
    Map<String, String> parametros = {
      "pagina": pagina!,
      "especie": selEspecie!,
      "raza": selRaza!,
      "departamento": selDepartamento!,
      "ciudad": selCiudad!,
      "barrio": selBarrio!
    };
    var result = await http.post(Uri.parse(PERDIDOS_LIST), body: parametros);
    if (result.statusCode == 200) {
      // If you are sure that your web service has json string, return it directly
      resp = result.body;
    }
    int pag = int.parse(pagina!) + 8;
    pagina = pag.toString();
    List lst = json.decode(resp);
    if (lst.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No hay mas posts")));
    }
    setState(() {
      cargando = false;
      posts.addAll(lst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mascotas Perdidas"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ExpansionTile(
                title: const Text('Filtros de busqueda'),
                leading: Icon(
                  Icons.filter_alt,
                  color: primaryColor,
                ),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 8),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 8),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 8),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 8),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 8),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        posts = [];
                        pagina = "0";
                        getReq();
                      },
                      icon: primaryIconButton(Icons.search),
                      label: Text(
                        "Filtrar",
                        style: primaryButtonText,
                      ),
                      style: primaryButton,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
            Container(
              constraints: const BoxConstraints(minHeight: 50),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Número de columnas
                    crossAxisSpacing: 5.0, // Espaciado horizontal
                    mainAxisSpacing: 5.0, // Espaciado vertical
                    childAspectRatio: 0.58),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  Map elem = posts[index];
                  return CardP(
                      postid: elem["postid"],
                      nombres: elem["nombres"],
                      lugar: elem["lugar"],
                      tipo: elem["especie"],
                      estado: elem["estado"],
                      recompensa: elem["recompensa"],
                      imagen: "$PERDIDOS_IMG/${elem["img"]}",
                      indice: index.toString());
                },
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
                    setState(() {
                      cargando = true;
                    });
                    getReq();
                  },
                  icon: primaryIconButton(Icons.restart_alt_outlined),
                  label: Text(
                    "Cargar mas posts",
                    style: primaryButtonText,
                  ),
                  style: primaryButton,
                ),
              )
          ],
        ),
      ),
    );
  }
}
