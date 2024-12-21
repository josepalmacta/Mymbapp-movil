import 'dart:convert';
import 'package:mymbapp/data/endpoints.dart';
import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/pages/edit_post_adopcion.dart';
import 'package:mymbapp/pages/editar_post_encontrado.dart';
import 'package:mymbapp/pages/editar_post_perdido.dart';
import 'package:mymbapp/pages/home_page.dart';
import 'package:mymbapp/pages/post_adopcion_page.dart';
import 'package:mymbapp/pages/post_encontrado_page.dart';
import 'package:mymbapp/pages/post_perdido_page.dart';
import 'package:mymbapp/utilidades/sesionToken.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:developer';

final GlobalKey<ScaffoldState> scaffoldMessengerKey =
    GlobalKey<ScaffoldState>();

class MisPublicacionesPage extends StatefulWidget {
  const MisPublicacionesPage({super.key});

  @override
  State<MisPublicacionesPage> createState() => _MisPublicacionesPageState();
}

class _MisPublicacionesPageState extends State<MisPublicacionesPage> {
  String token = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Publicaciones"),
      ),
      key: scaffoldMessengerKey,
      body: FutureBuilder(
          future: getPosts(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              List datos = snapshot.data!;
              return ListView.builder(
                itemCount: datos.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: listaPosts(datos[index]),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('No hay datos disponibles'));
            }
          }),
    );
  }

  Future<List> getPosts() async {
    String resp = "[]";
    bool a = await checkLogin();
    if (a) {
      Map<String, String> JsonBody = {'device': 'app', 'token': token};
      var result = await http.post(Uri.parse(MIS_POSTS), body: JsonBody);
      if (result.statusCode == 200) {
        resp = result.body;
        log(resp);
      }
    }
    return json.decode(resp);
  }

  List<Widget> listaPosts(Map obj) {
    List<Widget> rw = [];
    List<Widget> posts = [];
    List<Widget> content = [];
    Color clor = Colors.grey;

    IconData icono = Icons.search;

    if (obj["tipo"] == "encontrados") {
      icono = Icons.place;
    }
    if (obj["tipo"] == "adopcion") {
      icono = Icons.pets;
    }

    if (obj["sis_estado"] == "APROBADO") {
      clor = primaryColor;
    }

    posts.add(Text(obj["nombres"]));
    posts.add(const SizedBox(
      height: 5,
    ));
    posts.add(Text(obj["fecha"]));
    posts.add(const SizedBox(
      height: 5,
    ));
    posts.add(Badge(
      label: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          obj["sis_estado"],
        ),
      ),
      backgroundColor: clor,
    ));

    Column col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: posts,
    );

    rw.add(Icon(
      icono,
      color: primaryColor,
      size: 40,
    ));
    rw.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: col,
    ));

    Expanded ex1 = Expanded(
        child: Row(
      children: rw,
    ));

    content.add(ex1);

    if (obj["sis_estado"] == "APROBADO") {
      content.add(postMenu(obj["postid"], obj["tipo"], obj["estado"]));
    }

    return content;
  }

  Widget postMenu(String postid, String tipo, String estado) {
    return PopupMenuButton(
      itemBuilder: (BuildContext bc) {
        return [
          PopupMenuItem(
            onTap: () {
              Widget destino = PostPerdidoPage(postid: postid);
              if (tipo == "encontrados") {
                destino = PostEncontradoPage(postid: postid);
              }
              if (tipo == "adopcion") {
                destino = PostAdopcionPage(postid: postid);
              }
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => destino));
            },
            value: '/hello',
            child: const ListTile(
              leading: Icon(Icons.remove_red_eye),
              title: Text("Ver Publicacion"),
            ),
          ),
          PopupMenuItem(
            enabled: !(estado == "ADOPTADO" || estado == "LOCALIZADO"),
            onTap: () {
              Widget destino = EditarPostPerdidoPage(pid: postid);
              if (tipo == "encontrados") {
                destino = EditarPostEncontradoPage(pid: postid);
              }
              if (tipo == "adopcion") {
                destino = EditarPostAdopcionPage(pid: postid);
              }
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => destino));
            },
            value: postid,
            child: const ListTile(
              leading: Icon(Icons.edit),
              title: Text("Editar Publicacion"),
            ),
          ),
        ];
      },
    );
  }

  Future<bool> checkLogin() async {
    String? tkn = await getToken();
    if (tkn == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Debe iniciar sesion")));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      token = tkn;
      return true;
    }
    return false;
  }
}
