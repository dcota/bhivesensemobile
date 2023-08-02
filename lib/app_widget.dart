// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:bhivesensemobile/controller/app_controller.dart';
import 'login.dart';
import 'home.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(fontFamily: 'Montserrat'),
          initialRoute: '/',
          routes: {
            '/': (context) => MyApp(),
            '/login': (context) => LoginPage(),
          },
        );
      },
      animation: AppController.instance,
    );
  }
}
