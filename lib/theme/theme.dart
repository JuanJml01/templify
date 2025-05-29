import 'package:flutter/material.dart';

ThemeData themeLight = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 209, 171, 64),
  ),
);

ThemeData themeDark = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    brightness: Brightness.dark,
    seedColor: Colors.red,
  ),
);
