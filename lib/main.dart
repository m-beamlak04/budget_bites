import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';

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

  void _changeTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
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
