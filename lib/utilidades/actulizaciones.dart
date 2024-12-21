import 'dart:convert';
import 'package:mymbapp/data/endpoints.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:geolocator_apple/geolocator_apple.dart';
import 'dart:developer';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

actPosts() async {
  Map ubi = await getCurrentLocation();

  if (ubi["activado"]) {
    LatLng a = ubi["ubicacion"];
    List res = await getPerdidos(a.latitude.toString(), a.longitude.toString());

    if (res.isEmpty) {
      log("NO HAY");
      return;
    }

    bool u = await updateSwdNotif(res);

    if (!u) {
      log("ya se mostro");
      return;
    }

    if (res.length > 1) {
      multipleNotif(res.length.toString());
      return;
    }
    detNotif(
        res[0]["nombres"], res[0]["postid"], "$PERDIDOS_IMG/${res[0]["img"]}");
  }
}

Future<Map> getCurrentLocation() async {
  log("ubicacion");

  if (defaultTargetPlatform == TargetPlatform.android) {
    GeolocatorAndroid.registerWith();
  } else if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    GeolocatorApple.registerWith();
  }

  LocationPermission permi = await Geolocator.checkPermission();
  if (permi == LocationPermission.denied ||
      permi == LocationPermission.deniedForever ||
      permi == LocationPermission.unableToDetermine) {
    return {'activado': false};
  }
  Position pos = await Geolocator.getCurrentPosition();

  return {'activado': true, 'ubicacion': LatLng(pos.latitude, pos.longitude)};
}

Future<List> getPerdidos(String lat, String lng) async {
  String resp = "[]";
  Map postData = {'lat': lat, 'lng': lng};
  var result = await http.post(Uri.parse(UBI_NOTIF), body: postData);
  if (result.statusCode == 200) {
    // If you are sure that your web service has json string, return it directly
    resp = result.body;
  }
  return json.decode(resp);
}

void multipleNotif(String cantidad) {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      color: Colors.red,
      channelKey: 'channelNotiUbi',
      title: 'Mascotas perdidas en tu zona',
      body:
          "Hay $cantidad mascotas perdidas cerca de tu ubicacion actual. Si vez a alguno ayudanos reportandolo.",
      criticalAlert: true,
    ),
  );
}

void detNotif(String nombres, String postid, String img) {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      color: Colors.red,
      channelKey: 'channelNotiUbi',
      title: 'Se busca a $nombres',
      body:
          "Perdido cerca de tu ubicacion actual. Si tienes informacion, ayuda notificando a su propietario.",
      bigPicture: img,
      notificationLayout: NotificationLayout.BigPicture,
      criticalAlert: true,
    ),
  );
}

// Función para obtener el token desde el almacenamiento seguro
Future<String?> getSwdNotif() async {
  return await secureStorage.read(key: 'swddnotif');
}

// Función para guardar el token en el almacenamiento seguro
Future<void> saveSwdNotif(String notif) async {
  await secureStorage.write(key: 'swddnotif', value: notif);
}

// Función para eliminar el token (por ejemplo, al cerrar sesión)
Future<void> deleteSwdNotif() async {
  await secureStorage.delete(key: 'swddnotif');
}

Future<bool> updateSwdNotif(List l) async {
  List<String> res = l.map((mapa) => mapa["postid"]!.toString()).toList();

  String? notifs = await getSwdNotif();

  DateTime fecha = DateTime.now();

  String hoy = "${fecha.year}-${fecha.month}-${fecha.day}";

  Map obj =
      json.decode((notifs == null) ? '{"fecha": "$hoy", "swd":[]}' : notifs);

  if (hoy != obj["fecha"].toString()) {
    deleteSwdNotif();
    return true;
  }

  List swd = obj["swd"];

  if (!res.any((elemento) => swd.contains(elemento))) {
    swd.addAll(res.where((elemento) => !swd.contains(elemento)));
    obj["swd"] = swd;
    saveSwdNotif(json.encode(obj));
    return true;
  }
  return false;
}
