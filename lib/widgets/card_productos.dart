import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/pages/producto_pages.dart';
import 'package:flutter/material.dart';

class CardProd extends StatelessWidget {
  const CardProd(
      {super.key,
      required this.prodid,
      required this.nombre,
      required this.descripcion,
      required this.precio,
      required this.imagen,
      required this.stock,
      required this.indice});

  final String prodid;
  final String nombre;
  final String descripcion;
  final String precio;
  final String stock;
  final String imagen;
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
            builder: (context) => ProductoPage(prodid: prodid),
          ),
        );
      },
      child: Card(
        color: cardBackground,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 8.0,
                  ),
                  SizedBox(
                    height: 160,
                    width: 160,
                    child: Image.network(
                      imagen,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  SizedBox(
                    height: 35,
                    child: Text(
                      nombre,
                      style: styleBoldB,
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.currency_bitcoin,
                        size: 15,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      Text(
                        precio,
                        style: styleBold,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    "$stock en Stock",
                    style: styleSmall_2,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
