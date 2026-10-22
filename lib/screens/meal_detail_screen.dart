import 'package:flutter/material.dart';

import '../models/meal.dart';
import 'meal_form_screen.dart';
import '../database/database_helper.dart';

class MealDetailScreen extends StatelessWidget {
  final Meal meal;

  const MealDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              meal.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cuisine: ${meal.cuisine}'),
                    const SizedBox(height: 16),
                    Text('Venue: ${meal.venue}'),
                    const SizedBox(height: 16),
                    Text(
                      'Estimated Price: \$${meal.estimatedPrice.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealFormScreen(meal: meal),
                      ),
                    );

                    if (updated == true && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('Edit Meal'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text('Delete Meal?'),
                            content: Text(
                              'Are you sure you want to delete ${meal.name}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, false);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, true);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirmed != true || !context.mounted) return;

                      try {
                        final deletedRows = await DatabaseHelper.instance
                            .deleteMeal(meal.id!);

                        if (!context.mounted) return;

                        if (deletedRows == 1) {
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Meal could not be found.'),
                            ),
                          );
                        }
                      } catch (error) {
                        debugPrint('Error deleting meal: $error');

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to delete meal.'),
                          ),
                        );
                      }
                    },
                    child: const Text('Delete Meal'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Purchase Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No purchase activity yet.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
