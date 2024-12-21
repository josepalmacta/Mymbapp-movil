import 'dart:convert';
import 'package:mymbapp/data/endpoints.dart';
import 'package:mymbapp/pages/home_page.dart';
import 'package:mymbapp/utilidades/sesionToken.dart';
import 'package:http/http.dart' as http;
import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/utilidades/metodos.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:developer';

final _formkeyRegistro = GlobalKey<FormState>();
final _formkeyLogin = GlobalKey<FormState>();

class CuentaPage extends StatefulWidget {
  const CuentaPage({super.key});

  @override
  State<CuentaPage> createState() => _CuentaPageState();
}

class _CuentaPageState extends State<CuentaPage> {
  final PanelController loginPanelController = PanelController();
  final PanelController registerPanelController = PanelController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text("Acceso"),
      ),
      body: Stack(
        children: [
          // Fondo de la página
          Center(
              child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              SizedBox(
                height: 150,
                child: Image.asset("assets/img/logo2.png"),
              ),
              const SizedBox(
                height: 75,
              ),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    loginPanelController.open();
                  },
                  label: Text(
                    "Iniciar sesion",
                    style: primaryButtonText,
                  ),
                  style: thridButton,
                  icon: primaryIconButton(Icons.login),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    registerPanelController.open();
                  },
                  label: Text(
                    "Registro",
                    style: secondaryButtonText,
                  ),
                  style: secondaryButton,
                  icon: secondaryIconButton(Icons.app_registration),
                ),
              )
            ],
          )),

          SlidingUpPanel(
            controller: loginPanelController,
            minHeight: 1,
            maxHeight: 450,
            panel: _buildLoginPanel(),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),

          SlidingUpPanel(
            controller: registerPanelController,
            minHeight: 1,
            maxHeight: 600,
            panel: _buildRegisterPanel(),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPanel() {
    return LoginForm();
  }

  Widget _buildRegisterPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
      child: RegsitroForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final email_controller = TextEditingController();
  final passw_controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
      child: Form(
        key: _formkeyLogin,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              validator: validarEmail,
              controller: email_controller,
              decoration: inputStyle("Email", Icons.email),
            ),
            const SizedBox(
              height: 30,
            ),
            TextFormField(
              validator: validarPassw,
              controller: passw_controller,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: inputStyle("Contraseña", Icons.lock),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton.icon(
                icon: primaryIconButton(Icons.login),
                style: primaryButton,
                onPressed: () async {
                  if (!_formkeyLogin.currentState!.validate()) {
                    return;
                  }
                  bool a = await login(context);
                  if (a) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("BIENVENIDO")));
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  }
                },
                label: Text(
                  "Iniciar Sesion",
                  style: primaryButtonText,
                )),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> login(BuildContext ctx) async {
    bool retrn = false;
    String resp = "[]";
    Map<String, String> JsonBody = {
      'device': 'app',
      'email': email_controller.text,
      'clave': passw_controller.text
    };
    var result = await http.post(Uri.parse(CUENTA_LOGIN), body: JsonBody);
    if (result.statusCode == 200) {
      // If you are sure that your web service has json string, return it directly
      resp = result.body;
      Map obj = json.decode(resp);
      if (obj["success"] == true) {
        saveToken(obj["mensaje"]);
        retrn = true;
      } else {
        ScaffoldMessenger.of(ctx)
            .showSnackBar(SnackBar(content: Text(obj["mensaje"])));
      }
    }

    return retrn;
  }
}

class RegsitroForm extends StatefulWidget {
  const RegsitroForm({super.key});

  @override
  State<RegsitroForm> createState() => _RegsitroFormState();
}

class _RegsitroFormState extends State<RegsitroForm> {
  String? selDepartamento;
  String? selCiudad;
  String? selBarrio;
  List<Map<String, String>> departamentos = [];
  List<Map<String, String>> ciudades = [];
  List<Map<String, String>> barrios = [];

  final nombre_controller = TextEditingController();
  final email_controller = TextEditingController();
  final passw_controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarDepartamentos();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkeyRegistro,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            validator: validar,
            controller: nombre_controller,
            decoration: inputStyle("Nombre", Icons.person),
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            validator: validarEmail,
            controller: email_controller,
            decoration: inputStyle("Email", Icons.email),
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            validator: validarPassw,
            controller: passw_controller,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: inputStyle("Contraseña", Icons.lock),
          ),
          const SizedBox(
            height: 20,
          ),
          DropdownButtonFormField(
            isExpanded: true,
            decoration: DropDStyle("Departamento"),
            items: departamentos
                .map<DropdownMenuItem<String>>((Map<String, String> item) {
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
          const SizedBox(
            height: 20,
          ),
          DropdownButtonFormField(
            isExpanded: true,
            decoration: DropDStyle("Ciudad"),
            items: ciudades
                .map<DropdownMenuItem<String>>((Map<String, String> item) {
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
          const SizedBox(
            height: 20,
          ),
          DropdownButtonFormField(
            isExpanded: true,
            decoration: DropDStyle("Barrio"),
            items: barrios
                .map<DropdownMenuItem<String>>((Map<String, String> item) {
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
          const SizedBox(
            height: 20,
          ),
          ElevatedButton.icon(
              icon: primaryIconButton(Icons.app_registration),
              style: primaryButton,
              onPressed: () async {
                if (!_formkeyRegistro.currentState!.validate()) {
                  return;
                }
                bool a = await login(context);
                if (a) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("BIENVENIDO")));
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                }
              },
              label: Text(
                "Crear Cuenta",
                style: primaryButtonText,
              )),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  Future<void> cargarDepartamentos() async {
    var respuesta = await http.post(Uri.parse(DEPARTAMENTOS_LIST));
    if (respuesta.statusCode == 200) {
      log("reqq");
      List<dynamic> jsonResponse = json.decode(respuesta.body);
      setState(() {
        departamentos = jsonResponse.map((item) {
          return Map<String, String>.from(item);
        }).toList();
        selDepartamento = departamentos[0]["id"];
        if (selCiudad == null) {
          cargarCiudades();
        }
      });
    }
  }

  Future<void> cargarCiudades() async {
    Map parametros = {"departamento": selDepartamento};
    var respuesta = await http.post(Uri.parse(CIUDADES_LIST), body: parametros);
    if (respuesta.statusCode == 200) {
      setState(() {
        List<dynamic> jsonResponse = json.decode(respuesta.body);
        ciudades = jsonResponse.map((item) {
          return Map<String, String>.from(item);
        }).toList();
        selCiudad = ciudades[0]["id"];
        cargarBarrios();
      });
    }
  }

  Future<void> cargarBarrios() async {
    Map parametros = {"ciudad": selCiudad};
    var respuesta = await http.post(Uri.parse(BARRIOS_LIST), body: parametros);
    if (respuesta.statusCode == 200) {
      setState(() {
        List<dynamic> jsonResponse = json.decode(respuesta.body);
        barrios = jsonResponse.map((item) {
          return Map<String, String>.from(item);
        }).toList();
        selBarrio = barrios[0]["id"];
      });
    }
  }

  Future<bool> login(BuildContext ctx) async {
    bool retrn = false;
    String resp = "[]";
    Map<String, String> JsonBody = {
      'device': 'app',
      'nombre': nombre_controller.text,
      'email': email_controller.text,
      'clave': passw_controller.text,
      'barrio': selBarrio!
    };
    var result = await http.post(Uri.parse(CUENTA_REGISTRO), body: JsonBody);
    if (result.statusCode == 200) {
      // If you are sure that your web service has json string, return it directly
      resp = result.body;
      Map obj = json.decode(resp);
      if (obj["success"] == true) {
        saveToken(obj["mensaje"]);
        retrn = true;
      } else {
        ScaffoldMessenger.of(ctx)
            .showSnackBar(SnackBar(content: Text(obj["mensaje"])));
      }
    }

    return retrn;
  }
}
