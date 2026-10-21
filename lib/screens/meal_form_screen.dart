import 'package:flutter/material.dart';

class MealFormScreen extends StatelessWidget {
  const MealFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Meal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Meal Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Cuisine',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Venue',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Estimated Price',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextButton(onPressed: null, child: const Text('Save')),
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
