import 'package:flutter/material.dart';

class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              'Meal Name',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cuisine: —'),
                    SizedBox(height: 16),
                    Text('Venue: —'),
                    SizedBox(height: 16),
                    Text('Estimated Price: —'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: null,
                    child: const Text('Edit Meal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: null,
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
