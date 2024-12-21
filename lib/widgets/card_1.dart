import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/pages/post_perdido_page.dart';
import 'package:mymbapp/widgets/card_text.dart';
import 'package:flutter/material.dart';

class CardP extends StatelessWidget {
  const CardP(
      {super.key,
      required this.postid,
      required this.nombres,
      required this.lugar,
      required this.tipo,
      required this.imagen,
      required this.estado,
      required this.recompensa,
      required this.indice});

  final String postid;
  final String nombres;
  final String lugar;
  final String tipo;
  final String imagen;
  final String estado;
  final String recompensa;
  final String indice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final styleBold = theme.textTheme.displayLarge!.copyWith(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 15.0,
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostPerdidoPage(postid: postid),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    nombres,
                    style: styleBold,
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                card_text(txt: tipo, icono: Icons.pets),
                card_text(txt: lugar, icono: Icons.location_pin),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getBadge() {
    Color c = primaryColor;

    String msg = "RECOMPENSA";

    IconData i = Icons.card_giftcard;

    if (estado == "LOCALIZADO") {
      c = Colors.green[700]!;
      msg = "LOCALIZADO";
      i = Icons.check;
    }
    if (estado != "LOCALIZADO" && recompensa == "0") {
      return const SizedBox(
        height: 1,
      );
    }

    return Positioned(
      top: 5,
      right: 5,
      child: Badge(
        backgroundColor: c,
        label: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Icon(
                i,
                color: Colors.white,
                size: 15,
              ),
              const SizedBox(
                width: 3,
              ),
              Text(msg),
            ],
          ),
        ),
      ),
    );
  }
}
