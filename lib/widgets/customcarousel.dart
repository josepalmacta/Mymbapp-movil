import 'package:mymbapp/data/endpoints.dart';
import 'package:flutter/material.dart';

class CarouselExample extends StatefulWidget {
  const CarouselExample({super.key, required this.jsn, required this.tipo});
  final List jsn;
  final String tipo;
  @override
  State<CarouselExample> createState() => _CarouselExampleState();
}

class _CarouselExampleState extends State<CarouselExample> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 250),
        child: CarouselView(
            itemExtent: iEtx(widget.jsn, context),
            shrinkExtent: 200,
            children: getImages(widget.jsn, widget.tipo)),
      ),
    );
  }
}

double iEtx(List cantidad, BuildContext context) {
  return (cantidad.length > 1 || cantidad[0]["imgs"].length > 1)
      ? (MediaQuery.of(context).size.width * 95 / 100)
      : double.infinity;
}

class CarouselImages extends StatelessWidget {
  const CarouselImages({super.key, required this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Image.network(url, fit: BoxFit.cover),
    );
  }
}

List<Widget> getImages(List mapa, String tipo) {
  List<Widget> lista = [];
  for (var element in mapa) {
    for (var elem in element["imgs"]) {
      lista.add(CarouselImages(url: "$IMGS_POSTS/$tipo/$elem"));
    }
  }
  return lista;
}
