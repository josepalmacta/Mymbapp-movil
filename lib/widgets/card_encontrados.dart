import 'package:mymbapp/pages/post_encontrado_page.dart';
import 'package:mymbapp/widgets/card_text.dart';
import 'package:flutter/material.dart';

class CardE extends StatelessWidget {
  const CardE(
      {super.key,
      required this.postid,
      required this.lugar,
      required this.imagen,
      required this.estado,
      required this.indice});

  final String postid;
  final String lugar;
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
            builder: (context) => PostEncontradoPage(postid: postid),
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
                card_text(txt: lugar, icono: Icons.location_pin),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getBadge() {
    if (estado != "LOCALIZADO") {
      return const SizedBox(
        height: 1,
      );
    }

    return Positioned(
      top: 5,
      right: 5,
      child: Badge(
        backgroundColor: Colors.green[700],
        label: const Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.white,
                size: 15,
              ),
              SizedBox(
                width: 3,
              ),
              Text("LOCALIZADO"),
            ],
          ),
        ),
      ),
    );
  }
}
