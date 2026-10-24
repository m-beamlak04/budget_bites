import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/meal.dart';
import '../models/purchase_log.dart';
import '../services/lunch_lens_predictor.dart';

class LunchLensScreen extends StatefulWidget {
  const LunchLensScreen({super.key});

  @override
  State<LunchLensScreen> createState() => _LunchLensScreenState();
}

class _LunchLensScreenState extends State<LunchLensScreen> {
  List<Meal> _meals = [];
  List<PurchaseLog> _purchases = [];
  double _budget = 20.0;

  int? _predictedPrice(int mealId) {
    return LunchLensPredictor.predictPrice(mealId, _purchases);
  }

  int? _baselinePrice(int mealId) {
    return LunchLensPredictor.baselinePrice(mealId, _purchases);
  }

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _meals.map((meal) {
          final prediction = _predictedPrice(meal.id!);
          final baseline = _baselinePrice(meal.id!);

          return Card(
            child: ListTile(
              title: Text(meal.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prediction == null
                        ? 'Prediction: Not enough history'
                        : 'Prediction: \$${(prediction / 100).toStringAsFixed(2)}',
                  ),
                  Text(
                    baseline == null
                        ? 'Baseline: No purchase history'
                        : 'Baseline: \$${(baseline / 100).toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
