import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../database/database_helper.dart';

class MealFormScreen extends StatefulWidget {
  final Meal? meal;

  const MealFormScreen({super.key, this.meal});

  @override
  State<MealFormScreen> createState() => _MealFormScreenState();
}

class _MealFormScreenState extends State<MealFormScreen> {
  final _nameController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _venueController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.meal != null) {
      final meal = widget.meal!;

      _nameController.text = meal.name;
      _cuisineController.text = meal.cuisine;
      _venueController.text = meal.venue;
      _priceController.text = meal.estimatedPrice.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cuisineController.dispose();
    _venueController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveMeal() async {
    final name = _nameController.text.trim();
    final cuisine = _cuisineController.text.trim();
    final venue = _venueController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    if (name.isEmpty || cuisine.isEmpty || venue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (price == null || !price.isFinite || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price above 0.')),
      );
      return;
    }

    final meal = Meal(
      id: widget.meal?.id,
      name: name,
      cuisine: cuisine,
      venue: venue,
      estimatedPrice: price,
    );

    try {
      if (widget.meal == null) {
        await DatabaseHelper.instance.insertMeal(meal);
      } else {
        await DatabaseHelper.instance.updateMeal(meal);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      debugPrint('Error saving meal: $error');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save meal. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal == null ? 'Add Meal' : 'Edit Meal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Meal Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _cuisineController,
              decoration: const InputDecoration(
                labelText: 'Cuisine',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _venueController,
              decoration: const InputDecoration(
                labelText: 'Venue',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Estimated Price',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _saveMeal,
                    child: const Text('Save'),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
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
