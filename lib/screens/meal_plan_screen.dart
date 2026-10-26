import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/meal.dart';
import '../models/purchase_log.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  List<Meal> _meals = [];
  final Map<int, int> _quantities = {};
  bool _isSaving = false;

  // Calculates the estimated total using each meal's price and selected quantity
  double get _estimatedTotal {
    double total = 0;

    for (final meal in _meals) {
      final quantity = _quantities[meal.id] ?? 0;
      total += meal.estimatedPrice * quantity;
    }

    return total;
  }

  // Counts the total number of meal items selected
  int get _selectedMealCount {
    int count = 0;

    for (final quantity in _quantities.values) {
      count += quantity;
    }

    return count;
  }

  // Asks for confirmation before clearing the current meal selections
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

  // Checks that the actual price is valid and has at most two decimal places
  String? _validatePrice(String input) {
    final text = input.trim();
    final price = double.tryParse(text);

    if (price == null) {
      return 'Enter a valid price.';
    }

    if (!price.isFinite || price < 0) {
      return 'Price must be zero or greater.';
    }

    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text)) {
      return 'Use at most 2 decimal places.';
    }

    return null;
  }

  // Opens the review dialog and saves the purchases after confirmation
  Future<void> _finishPlan() async {
    final selectedMeals = _meals
        .where((meal) => (_quantities[meal.id] ?? 0) > 0)
        .toList();

    final priceControllers = <int, TextEditingController>{};

    for (final meal in selectedMeals) {
      priceControllers[meal.id!] = TextEditingController(
        text: meal.estimatedPrice.toStringAsFixed(2),
      );
    }

    final confirmedPurchases = await showDialog<Map<int, int>>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Review Meal Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final meal in selectedMeals)
              ListTile(
                title: Text(meal.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity: ${_quantities[meal.id]}'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceControllers[meal.id],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Actual Price (per meal)',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              for (final meal in selectedMeals) {
                final input = priceControllers[meal.id]!.text;
                final error = _validatePrice(input);

                if (error != null) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('${meal.name}: $error')),
                  );
                  return;
                }
              }

              // Stores each meal's actual price in cents using its ID as the key
              final purchaseData = <int, int>{};

              for (final meal in selectedMeals) {
                final input = priceControllers[meal.id]!.text.trim();
                final actualPrice = double.parse(input);

                purchaseData[meal.id!] = (actualPrice * 100).round();
              }

              Navigator.pop(context, purchaseData);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmedPurchases == null || !mounted || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _savePlanPurchases(selectedMeals, confirmedPurchases);

      if (!mounted) return;

      setState(() {
        _quantities.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal plan purchases saved successfully!'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save meal plan purchases.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Creates a separate purchase record for each selected meal quantity
  Future<void> _savePlanPurchases(
    List<Meal> selectedMeals,
    Map<int, int> purchaseData,
  ) async {
    for (final meal in selectedMeals) {
      final quantity = _quantities[meal.id] ?? 0;
      final actualPriceMinor = purchaseData[meal.id]!;

      for (int i = 0; i < quantity; i++) {
        final purchase = PurchaseLog(
          mealId: meal.id!,
          purchasedAt: DateTime.now(),
          actualPriceMinor: actualPriceMinor,
        );

        await DatabaseHelper.instance.insertPurchase(purchase);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  // Loads available meals from the database for the meal plan
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

                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedMealCount > 0 && !_isSaving
                        ? _finishPlan
                        : null,
                    child: const Text('Finish'),
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
