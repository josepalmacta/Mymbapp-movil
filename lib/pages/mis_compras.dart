import 'dart:convert';
import 'package:mymbapp/data/endpoints.dart';
import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/pages/compra_detalle_page.dart';
import 'package:mymbapp/pages/home_page.dart';
import 'package:mymbapp/utilidades/sesionToken.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:developer';

final GlobalKey<ScaffoldState> scaffoldMessengerKey =
    GlobalKey<ScaffoldState>();

class MisComprasPage extends StatefulWidget {
  const MisComprasPage({super.key});

  @override
  State<MisComprasPage> createState() => _MisComprasPageState();
}

class _MisComprasPageState extends State<MisComprasPage> {
  String token = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Compras"),
        backgroundColor: primaryColor,
      ),
      key: scaffoldMessengerKey,
      body: FutureBuilder(
          future: getCompras(),
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
                    padding: const EdgeInsets.all(5.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CompraPage(
                                      compraid: datos[index]["ventid"],
                                    )));
                      },
                      child: Card(
                        color: cardBackground,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10),
                          child: Row(
                            children: listaCompras(datos[index]),
                          ),
                        ),
                      ),
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

  Future<List> getCompras() async {
    String resp = "[]";
    bool a = await checkLogin();
    if (a) {
      Map<String, String> JsonBody = {'device': 'app', 'token': token};
      var result = await http.post(Uri.parse(MIS_COMPRAS), body: JsonBody);
      log(result.body);
      if (result.statusCode == 200) {
        resp = result.body;
      }
    }
    return json.decode(resp);
  }

  List<Widget> listaCompras(Map obj) {
    List<Widget> rw = [];
    List<Widget> posts = [];
    List<Widget> content = [];

    Color colr = Colors.grey;

    if (obj["estado"] == "FINALIZADO") {
      colr = Colors.green[700]!;
    }
    if (obj["estado"] == "ENVIADO") {
      colr = Colors.teal[200]!;
    }
    if (obj["estado"] == "ENTREGADO") {
      colr = primaryColor;
    }

    String cid = obj["ventid"];

    posts.add(Text(
      "Pedido #$cid",
      style: styleBold_2,
    ));
    posts.add(const SizedBox(
      height: 5,
    ));
    posts.add(Text(
      formatFecha(obj["fecha"]),
      style: styleSmall_1,
    ));
    posts.add(const SizedBox(
      height: 5,
    ));

    Column col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: posts,
    );

    rw.add(Icon(
      Icons.shopping_cart,
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

    content.add(Badge(
        backgroundColor: colr,
        label: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(obj["estado"]),
        )));

    return content;
  }

  String formatFecha(String f) {
    var a = f.split("-");
    return "${a[2]}/${a[1]}/${a[0]}";
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
