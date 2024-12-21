import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:mymbapp/data/estilos.dart';
import 'package:mymbapp/data/globals.dart';
import 'package:mymbapp/pages/home_page.dart';
import 'package:mymbapp/utilidades/actulizaciones.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Your background task logic goes here
    log("callbackDispatcher");
    try {
      await actPosts();
    } catch (e) {
      log("error");
      log(e.toString());
    }

    addTask();
    return Future.value(true);
  });
}

void addTask() {
  Workmanager().registerOneOffTask("taskNotiUbi", "taskNotiUbi",
      initialDelay: Duration(minutes: 1),
      existingWorkPolicy: ExistingWorkPolicy.append);
}

void main() {
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
        ledColor: Colors.pink,
        enableVibration: true,
        channelKey: "channelNotiUbi",
        channelName: "NotiUbi",
        channelDescription: 'Notificaciones por ubicacion')
  ]);
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);
  addTask();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white //here you can give the text color
            ),
        colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor, surface: Colors.white),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },
    );
  }
}
