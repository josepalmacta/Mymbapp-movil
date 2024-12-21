import 'package:mymbapp/pages/post_adopcion_page.dart';
import 'package:mymbapp/widgets/card_text.dart';
import 'package:flutter/material.dart';

class CardA extends StatelessWidget {
  const CardA(
      {super.key,
      required this.postid,
      required this.tipo,
      required this.genero,
      required this.imagen,
      required this.estado,
      required this.indice});

  final String postid;
  final String tipo;
  final String genero;
  final String imagen;
  final String estado;
  final String indice;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostAdopcionPage(postid: postid),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              SizedBox(
                height: 200,
                width: 200,
                child: Image.network(imagen, fit: BoxFit.fill, errorBuilder:
                    (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                  return const SizedBox(
                      height: 200,
                      width: 200,
                      child: Center(child: Icon(Icons.error)));
                }),
              ),
              getBadge()
            ]),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                card_text(txt: tipo, icono: Icons.pets),
                card_text(txt: genero, icono: Icons.male),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getBadge() {
    if (estado != "ADOPTADO") {
      return const SizedBox(
        height: 1,
      );
    }

    return Positioned(
      top: 5,
      right: 5,
      child: Badge(
        backgroundColor: Colors.red[400],
        label: const Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Icon(
                Icons.favorite,
                color: Colors.white,
                size: 15,
              ),
              SizedBox(
                width: 3,
              ),
              Text("ADOPTADO"),
            ],
          ),
        ),
      ),
    );
  }
}
