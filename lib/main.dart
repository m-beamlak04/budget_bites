import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';

void main() {
  runApp(const BudgetBitesApp());
}

class BudgetBitesApp extends StatelessWidget {
  const BudgetBitesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Bites',
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}
