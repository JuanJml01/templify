import 'package:flutter/material.dart';
import 'package:templify/theme/theme.dart';
import 'package:templify/view/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowMaterialGrid: false,
      title: 'Templify',
      theme: themeLight,
      darkTheme: themeDark,
      home: Home(),
      routes: {"/home": (context) => Home()},
      initialRoute: "/home",
      themeMode: ThemeMode.system,
    );
  }
}
