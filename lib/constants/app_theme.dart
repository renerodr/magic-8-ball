import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _coral = Color(0xFFFF6B6B);
const Color _teal = Color(0xFF4ECDC4);

const Color _lightBg = Color(0xFFFAF7F2);
const Color _darkBg = Color(0xFF1A1A23);
const Color _darkSurface = Color(0xFF252530);

const Color _lightTextPrimary = Color(0xFF1A1A23);
const Color _lightTextSecondary = Color(0xFF6B6B7B);
const Color _darkTextPrimary = Color(0xFFFAF7F2);
const Color _darkTextSecondary = Color(0xFF8A8A9A);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _darkBg,
  colorScheme: const ColorScheme.dark(
    primary: _coral,
    secondary: _teal,
    surface: _darkSurface,
    onSurface: _darkTextPrimary,
    onSurfaceVariant: _darkTextSecondary,
  ),
  textTheme: _buildTextTheme(isDark: true),
);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: _lightBg,
  colorScheme: const ColorScheme.light(
    primary: _coral,
    secondary: _teal,
    surface: Colors.white,
    onSurface: _lightTextPrimary,
    onSurfaceVariant: _lightTextSecondary,
  ),
  textTheme: _buildTextTheme(isDark: false),
);

TextTheme _buildTextTheme({required bool isDark}) {
  final primaryColor = isDark ? _darkTextPrimary : _lightTextPrimary;
  final secondaryColor = isDark ? _darkTextSecondary : _lightTextSecondary;

  return TextTheme(
    displayLarge: GoogleFonts.nunito(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: primaryColor,
      letterSpacing: 0.5,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: primaryColor,
      letterSpacing: 0.3,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: secondaryColor,
      letterSpacing: 0.3,
    ),
  );
}
