import 'package:flutter/material.dart';

class MealFormScreen extends StatelessWidget {
  const MealFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal'),
      ),
      body: const Center(
        child: Text('Meal form will appear here.'),
      ),
    );
  }
}