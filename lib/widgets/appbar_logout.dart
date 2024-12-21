import 'package:mymbapp/data/endpoints.dart';
import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/pages/crear_post_adopcion.dart';
import 'package:mymbapp/pages/crear_post_encontrado.dart';
import 'package:mymbapp/pages/crear_post_perdido.dart';
import 'package:mymbapp/pages/cuenta_page.dart';
import 'package:mymbapp/pages/home_page.dart';
import 'package:mymbapp/pages/mis_compras.dart';
import 'package:mymbapp/pages/mis_publicaciones_page.dart';
import 'package:mymbapp/pages/posts_adopcion_page.dart';
import 'package:mymbapp/pages/posts_encontrados_page.dart';
import 'package:mymbapp/pages/posts_perdidos_page.dart';
import 'package:mymbapp/pages/tienda_pages.dart';
import 'package:mymbapp/utilidades/sesionToken.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AppbarLogout extends StatefulWidget implements PreferredSizeWidget {
  const AppbarLogout({super.key});

  @override
  State<AppbarLogout> createState() => _AppbarLogoutState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _AppbarLogoutState extends State<AppbarLogout> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: primaryColor,
      title: const Text(
        "MymbApp",
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Image.asset(
              "assets/img/logo2.png",
              height: 30,
              width: 30,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ))
      ],
    );
  }
}

class HeaderLogged extends StatelessWidget {
  const HeaderLogged({super.key, required this.nombre, required this.img});

  final String nombre;
  final String img;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          SizedBox(
            height: 85,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: Center(
                  child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor,
                    backgroundImage: NetworkImage(img),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    nombre,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
            ),
          ),
          const MenuItm(
              icono: Icons.logout,
              titulo: "Cerrar Sesion",
              destino: HomePage()),
          const MenuItm(
              icono: Icons.file_copy,
              titulo: "Mis Publicaciones",
              destino: MisPublicacionesPage()),
          const MenuItm(
              icono: Icons.shopping_cart,
              titulo: "Mis Compras",
              destino: MisComprasPage()),
          const CrearPostMenu(),
        ],
      ),
    );
  }
}

class HeaderLogout extends StatelessWidget {
  const HeaderLogout({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          SizedBox(
            height: 85,
            child: DrawerHeader(
                decoration: BoxDecoration(
                  color: primaryColor,
                ),
                child: const Align(
                  child: Text("Bienvenido",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )),
          ),
          ListTile(
            leading: Icon(
              Icons.login,
              color: primaryColor,
            ),
            title: const Text('Acceder'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CuentaPage()));
            },
          ),
          const CrearPostMenu()
        ],
      ),
    );
  }
}

Future<Widget> buildDrawerHeader() async {
  String? token = await getToken();
  if (token == null) {
    return const HeaderLogout();
  } else {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String userName =
        decodedToken['unombre']; // Asegúrate de que tu token tenga estos campos
    String userPhoto =
        decodedToken['uimg']; // Ruta o URL de la foto del usuario
    return HeaderLogged(nombre: userName, img: "$USER_IMG/$userPhoto");
  }
}

class MenuItm extends StatelessWidget {
  const MenuItm(
      {super.key,
      required this.icono,
      required this.titulo,
      required this.destino});

  final icono;
  final titulo;
  final destino;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icono,
        color: primaryColor,
      ),
      title: Text(titulo),
      onTap: () async {
        if (titulo == "Cerrar Sesion") {
          await deleteToken();
        }
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => destino));
      },
    );
  }
}

class CrearPostMenu extends StatelessWidget {
  const CrearPostMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          title: const Text('Crear Publicacion'),
          leading: Icon(
            Icons.post_add,
            color: primaryColor,
          ),
          children: const <Widget>[
            MenuItm(
                icono: Icons.search,
                titulo: "Perdi a mi mascota",
                destino: CrearPostPerdidoPage()),
            MenuItm(
                icono: Icons.place,
                titulo: "Encontre a una mascota",
                destino: CrearPostEncontradoPage()),
            MenuItm(
                icono: Icons.pets,
                titulo: "Quiero dar en adopcion",
                destino: CrearPostAdopcionPage()),
          ],
        ),
        const MenuItm(
            icono: Icons.search,
            titulo: "Mascotas Perdidas",
            destino: PostsPerdidosPage()),
        const MenuItm(
            icono: Icons.place,
            titulo: "Mascotas Encontradas",
            destino: PostsEncontradosPage()),
        const MenuItm(
            icono: Icons.pets,
            titulo: "Mascotas en Adopcion",
            destino: PostsAdopcionPage()),
        const MenuItm(
            icono: Icons.store, titulo: "Tienda", destino: TiendaPage()),
      ],
    );
  }
}
