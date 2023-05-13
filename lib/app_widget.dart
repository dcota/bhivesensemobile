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
          //debugShowCheckedModeBanner: true,
          theme: ThemeData(fontFamily: 'Montserrat'
              //primaryColor: Colors.green,
              ),
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

/*MaterialColor someThemeSwatch(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });

  return MaterialColor(color.value, swatch);
}*/
