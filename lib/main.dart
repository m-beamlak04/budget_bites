import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const BudgetBitesApp());
}

class BudgetBitesApp extends StatefulWidget {
  const BudgetBitesApp({super.key});

  @override
  State<BudgetBitesApp> createState() => _BudgetBitesAppState();
}

class _BudgetBitesAppState extends State<BudgetBitesApp> {
  bool _isDarkMode = false;

  Future<void> _saveTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getBool('dark_mode');

    if (!mounted) return;

    setState(() {
      _isDarkMode = savedTheme ?? false;
    });
  }

  Future<void> _changeTheme(bool value) async {
    setState(() {
      _isDarkMode = value;
    });

    await _saveTheme(value);
  }

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Bites',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: DashboardScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: _changeTheme,
      ),
    );
  }
}
