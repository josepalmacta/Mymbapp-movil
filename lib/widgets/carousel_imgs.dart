import 'package:flutter/material.dart';

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
