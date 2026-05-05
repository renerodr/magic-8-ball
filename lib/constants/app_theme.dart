import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0A0A0F),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF3D1A8E),
    secondary: Color(0xFF7C4DFF),
    surface: Color(0xFF12111A),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 1.2,
    ),
  ),
);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF5F0FF),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF4A0080),
    secondary: Color(0xFF9C27B0),
    surface: Colors.white,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1A0040),
      letterSpacing: 1.2,
    ),
  ),
);
