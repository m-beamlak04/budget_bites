import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/meal.dart';

import 'meal_detail_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import 'meal_form_screen.dart';
import 'meal_plan_screen.dart';
import 'lunch_lens_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const DashboardScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Meal> _meals = [];
  String _selectedCuisine = 'All';
  bool _isLoading = true;

  List<String> get _cuisines {
    final cuisines = _meals.map((meal) => meal.cuisine).toSet().toList();
    cuisines.sort();

    return ['All', ...cuisines];
  }

  List<Meal> get _filteredMeals {
    if (_selectedCuisine == 'All') {
      return _meals;
    }

    return _meals.where((meal) {
      return meal.cuisine == _selectedCuisine;
    }).toList();
  }

  Future<void> _loadMeals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final meals = await DatabaseHelper.instance.getAllMeals();

      if (!mounted) return;

      setState(() {
        _meals = meals;

        if (_selectedCuisine != 'All' &&
            !meals.any((meal) => meal.cuisine == _selectedCuisine)) {
          _selectedCuisine = 'All';
        }
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load meals. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Bites')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Meal Plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('No active meal plan'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MealPlanScreen(),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 8),
                            Text('Start Meal Plan'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Meal Catalog',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCuisine,
                        isDense: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        items: _cuisines.map((cuisine) {
                          return DropdownMenuItem<String>(
                            value: cuisine,
                            child: Text(
                              cuisine == 'All' ? 'All Cuisines' : cuisine,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _selectedCuisine = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_meals.isEmpty)
                  const Text('No meals added yet.')
                else
                  ..._filteredMeals.map((meal) {
                    return Card(
                      child: ListTile(
                        onTap: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MealDetailScreen(meal: meal),
                            ),
                          );

                          if (updated == true && mounted) {
                            _loadMeals();
                          }
                        },
                        title: Text(meal.name),
                        subtitle: Text('${meal.cuisine} • ${meal.venue}'),
                        trailing: Text(
                          '\$${meal.estimatedPrice.toStringAsFixed(2)}',
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final saved = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MealFormScreen(),
                        ),
                      );

                      if (!mounted) return;

                      if (saved == true) {
                        await _loadMeals();
                      }
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 8),
                        Text('Add Meal'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LunchLensScreen(),
                    ),
                  );
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome),
                    SizedBox(height: 4),
                    Text('Lunch Lens', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history),
                    SizedBox(height: 4),
                    Text('History', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                        isDarkMode: widget.isDarkMode,
                        onThemeChanged: widget.onThemeChanged,
                      ),
                    ),
                  );
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.settings),
                    SizedBox(height: 4),
                    Text('Settings', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
