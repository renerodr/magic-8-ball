import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0A0A0F),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF6D28D9),
    secondary: Color(0xFFA78BFA),
    surface: Color(0xFF12111A),
  ),
  textTheme: _expressivetextTheme,
);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF5F0FF),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF7C3AED),
    secondary: Color(0xFFA855F7),
    surface: Colors.white,
  ),
  textTheme: _expressivetextTheme,
);

TextTheme get _expressivetextTheme => TextTheme(
      displayLarge: GoogleFonts.cormorantGaramond(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 1.0,
        height: 1.3,
      ),
    );
