import 'package:flutter/material.dart';

class AppTheme {
  // Colores base para modo claro / oscuro
  static const _lightSeed = Color(0xFF6750A4);
  static const _darkSeed = Color(0xFF8B7BD9);

  static ThemeData light({Color? seed}) => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed ?? _lightSeed,
        brightness: Brightness.light,
      );

  static ThemeData dark({Color? seed}) => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed ?? _darkSeed,
        brightness: Brightness.dark,
      );

  /// Presets rápidos para cambiar el "look" de la app.
  static const presets = <String, Color>{
    'Lavanda': Color(0xFF6750A4),
    'Menta': Color(0xFF00B894),
    'Coral': Color(0xFFFF6B6B),
    'Atardecer': Color(0xFFFF8E53),
    'Océano': Color(0xFF0984E3),
    'Lima': Color(0xFF7CB342),
    'Noche': Color(0xFF1A237E),
  };
}
