import 'package:mymbapp/data/endpoints.dart';
import 'package:flutter/material.dart';

class CarouselProducto extends StatefulWidget {
  const CarouselProducto({super.key, required this.jsn});
  final List jsn;
  @override
  State<CarouselProducto> createState() => _CarouselProductoState();
}

class _CarouselProductoState extends State<CarouselProducto> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 250),
        child: CarouselView(
            itemExtent: double.infinity,
            shrinkExtent: 200,
            children: getImages(widget.jsn)),
      ),
    );
  }
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

List<Widget> getImages(List mapa) {
  List<Widget> lista = [];
  for (var element in mapa) {
    lista.add(CarouselImages(url: "$PRODUCTO_IMG/$element"));
  }
  return lista;
}
