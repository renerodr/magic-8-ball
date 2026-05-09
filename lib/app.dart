import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

class MagicApp extends StatefulWidget {
  const MagicApp({super.key});

  @override
  State<MagicApp> createState() => _MagicAppState();
}

class _MagicAppState extends State<MagicApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _hasSeenOnboarding = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
  }

  Future<void> _loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      _isLoading = false;
    });
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    setState(() => _hasSeenOnboarding = true);
  }

  void _toggleTheme() => setState(() {
        _themeMode =
            _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      });

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: _themeMode,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Magic 8-Ball',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: _hasSeenOnboarding
          ? HomeScreen(onToggleTheme: _toggleTheme)
          : OnboardingScreen(onComplete: _completeOnboarding),
      navigatorObservers: [],
      routes: {
        '/daily': (context) => HomeScreen(onToggleTheme: _toggleTheme),
      },
    );
  }
}
