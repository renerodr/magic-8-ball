import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';

class MagicApp extends StatefulWidget {
  const MagicApp({super.key});

  @override
  State<MagicApp> createState() => _MagicAppState();
}

class _MagicAppState extends State<MagicApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() => setState(() {
        _themeMode =
            _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic 8-Ball',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: HomeScreen(onToggleTheme: _toggleTheme),
    );
  }
}
