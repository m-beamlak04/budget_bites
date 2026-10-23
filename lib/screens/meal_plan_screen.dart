import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/meal.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  List<Meal> _meals = [];
  final Map<int, int> _quantities = {};

  double get _estimatedTotal {
    double total = 0;

    for (final meal in _meals) {
      final quantity = _quantities[meal.id] ?? 0;
      total += meal.estimatedPrice * quantity;
    }

    return total;
  }

  int get _selectedMealCount {
    int count = 0;

    for (final quantity in _quantities.values) {
      count += quantity;
    }

    return count;
  }

  Future<void> _resetPlan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Meal Plan?'),
        content: const Text(
          'This will clear all selected meals. No purchases will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _quantities.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    final meals = await DatabaseHelper.instance.getAllMeals();

    if (!mounted) return;

    setState(() {
      _meals = meals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Active Meal Plan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_meals.isEmpty)
              const Text('No meals available. Add a meal first.')
            else
              ..._meals.map((meal) {
                final quantity = _quantities[meal.id] ?? 0;
                final subtotal = meal.estimatedPrice * quantity;
                return Card(
                  child: ListTile(
                    title: Text(meal.name),
                    subtitle: Text(
                      'Estimated Price: \$${meal.estimatedPrice.toStringAsFixed(2)}\n'
                          'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              final current = _quantities[meal.id] ?? 0;

                              if (current > 0) {
                                _quantities[meal.id!] = current - 1;
                              }
                            });
                          },
                        ),
                        Text('${_quantities[meal.id] ?? 0}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              final current = _quantities[meal.id] ?? 0;
                              _quantities[meal.id!] = current + 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 24),

            Text(
              'Estimated Total: \$${_estimatedTotal.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status: In Progress'),
                    const SizedBox(height: 24),
                    Text('$_selectedMealCount meals selected'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _selectedMealCount > 0 ? _resetPlan : null,
                    child: const Text('Reset'),
                  ),
                ),

                const SizedBox(width: 16),

                const Expanded(
                  child: ElevatedButton(
                    onPressed: null,
                    child: Text('Finish'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
