import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/meal.dart';
import '../models/purchase_log.dart';

class LunchLensScreen extends StatefulWidget {
  const LunchLensScreen({super.key});

  @override
  State<LunchLensScreen> createState() => _LunchLensScreenState();
}

class _LunchLensScreenState extends State<LunchLensScreen> {
  List<Meal> _meals = [];
  List<PurchaseLog> _purchases = [];
  double _budget = 20.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final meals = await DatabaseHelper.instance.getAllMeals();
    final purchases = await DatabaseHelper.instance.getAllPurchases();
    final prefs = await SharedPreferences.getInstance();
    final savedBudget = prefs.getDouble('meal_budget');

    if (!mounted) return;

    setState(() {
      _meals = meals;
      _purchases = purchases;
      _budget = savedBudget ?? 20.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lunch Lens')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Saved Meals: ${_meals.length}'),
            Text('Purchase Records: ${_purchases.length}'),
            Text('Budget: \$${_budget.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
