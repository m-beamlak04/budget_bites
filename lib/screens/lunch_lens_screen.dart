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

  bool? _isAffordable(int mealId) {
    final prediction = _predictedPrice(mealId);

    if (prediction == null) {
      return null;
    }

    return prediction <= (_budget * 100).round();
  }

  List<PurchaseLog> _recentPurchases(int mealId) {
    return LunchLensPredictor.getMealPurchases(
      mealId,
      _purchases,
    ).take(3).toList();
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
          final affordable = _isAffordable(meal.id!);
          final recentPurchases = _recentPurchases(meal.id!);


          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meal.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (affordable != null)
                        Text(
                          affordable ? 'Affordable' : 'Over budget',
                          style: TextStyle(
                            color: affordable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (prediction == null) ...[
                    const Text('Not enough history to predict'),
                    const SizedBox(height: 8),
                    Text(
                      baseline == null
                          ? 'Baseline: No purchase history'
                          : 'Baseline: \$${(baseline / 100).toStringAsFixed(2)}',
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Predicted price'),
                              Text(
                                '\$${(prediction / 100).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Baseline'),
                              Text(
                                baseline == null
                                    ? 'N/A'
                                    : '\$${(baseline / 100).toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    const Text(
                      'PREDICTION DETAILS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Last 3 purchases: '
                          '${recentPurchases.map((purchase) => '\$${(purchase.actualPriceMinor / 100).toStringAsFixed(2)}').join(', ')}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Purchase dates: '
                          '${DateUtils.isSameDay(
                        recentPurchases.first.purchasedAt,
                        recentPurchases.last.purchasedAt,
                      )
                          ? '${recentPurchases.first.purchasedAt.month}/${recentPurchases.first.purchasedAt.day}/${recentPurchases.first.purchasedAt.year}'
                          : '${recentPurchases.last.purchasedAt.month}/${recentPurchases.last.purchasedAt.day}/${recentPurchases.last.purchasedAt.year} - ${recentPurchases.first.purchasedAt.month}/${recentPurchases.first.purchasedAt.day}/${recentPurchases.first.purchasedAt.year}'}',
                    ),
                  ],
                ],
              ),
            ),
          );

        }).toList(),
      ),
    );
  }
}
