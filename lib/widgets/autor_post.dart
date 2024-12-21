import 'package:mymbapp/data/endpoints.dart';
import 'package:mymbapp/data/estilos.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer';

class cardContacto extends StatefulWidget {
  const cardContacto(
      {super.key,
      required this.persona,
      required this.per_ciu,
      required this.numero,
      required this.img,
      required this.tipo,
      required this.postid});
  final String persona;
  final String per_ciu;
  final String numero;
  final String img;
  final String tipo;
  final String postid;

  @override
  State<cardContacto> createState() => _cardContactoState();
}

class _cardContactoState extends State<cardContacto> {
  bool isShow = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardBackground,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.img),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.persona,
                          style: styleBold,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.place,
                              size: 12,
                              color: primaryColor,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              widget.per_ciu,
                              style: styleSmall_1,
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Contactar",
                  style: styleBold,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {
                          var contact = "+595${widget.numero.substring(1)}";
                          var sUrl =
                              "https://wa.me/$contact?text=${Uri.parse('Hola')}";

                          try {
                            launchUrl(Uri.parse(sUrl));
                          } on Exception {
                            log("wa error");
                          }
                        },
                        icon: primaryIconButton(Icons.phone_in_talk),
                        label: Text(
                          "WhatsApp",
                          style: primaryButtonText,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    SizedBox(
                        width: 150,
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                            ),
                            onPressed: () {
                              var contact = "+595${widget.numero.substring(1)}";
                              var sUrl = "tel:$contact";
                              try {
                                launchUrl(Uri.parse(sUrl));
                              } on Exception {
                                log("Error al llamar");
                              }
                            },
                            icon: primaryIconButton(Icons.phone),
                            label: Text(
                              "Llamar",
                              style: primaryButtonText,
                            ))),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(),
                ListTile(
                  title: const Text("Compartir Publicacion"),
                  leading: const Icon(Icons.share),
                  onTap: () async {
                    final result = await Share.shareUri(Uri.parse(
                        "$URL_GLOBAL/${widget.tipo}/post/${widget.postid}"));
                    if (result.status == ShareResultStatus.success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Gracias por compartir!")));
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
