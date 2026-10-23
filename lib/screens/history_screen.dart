import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/purchase_log.dart';
import '../models/meal.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<PurchaseLog> _purchases = [];
  List<Meal> _meals = [];

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    final purchases = await DatabaseHelper.instance.getAllPurchases();
    final meals = await DatabaseHelper.instance.getAllMeals();

    if (!mounted) return;

    setState(() {
      _purchases = purchases;
      _meals = meals;
    });
  }

  Future<void> _showPurchaseDialog({PurchaseLog? existingPurchase}) async {
    final List<Meal> meals = await DatabaseHelper.instance.getAllMeals();

    if (!mounted) return;
    int? selectedMealId = existingPurchase?.mealId;

    final priceController = TextEditingController(
      text: existingPurchase == null
          ? ''
          : (existingPurchase.actualPriceMinor / 100).toStringAsFixed(2),
    );

    DateTime selectedDate = existingPurchase?.purchasedAt ?? DateTime.now();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existingPurchase == null ? 'Add Purchase' : 'Edit Purchase',
              ),
              content: meals.isEmpty
                  ? const Text('No meals available. Add a meal first.')
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: selectedMealId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Select Meal',
                            prefixIcon: const Icon(Icons.restaurant_menu),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          items: meals.map((meal) {
                            return DropdownMenuItem<int>(
                              value: meal.id,
                              child: Text(
                                meal.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedMealId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Actual Price',
                            hintText: '0.00',
                            prefixIcon: const Icon(Icons.attach_money),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Purchase Date'),
                          subtitle: Text(
                            '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
                          ),
                          trailing: const Icon(Icons.arrow_drop_down),
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              setDialogState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: meals.isEmpty
                      ? null
                      : () async {
                          if (selectedMealId == null) {
                            setDialogState(() {
                              errorMessage = 'Please select a meal.';
                            });
                            return;
                          }

                          final priceText = priceController.text.trim();
                          final price = double.tryParse(priceText);

                          if (price == null ||
                              !price.isFinite ||
                              price <= 0 ||
                              !RegExp(r'^\d+(\.\d{1,2})?$')
                                  .hasMatch(priceText)) {
                            setDialogState(() {
                              errorMessage = 'Enter a valid price (e.g. 9.75).';
                            });
                            return;
                          }

                          final priceMinor = (price * 100).round();

                          final purchase = PurchaseLog(
                            id: existingPurchase?.id,
                            mealId: selectedMealId!,
                            purchasedAt: selectedDate,
                            actualPriceMinor: priceMinor,
                          );

                          if (existingPurchase == null) {
                            await DatabaseHelper.instance.insertPurchase(purchase);
                          } else {
                            await DatabaseHelper.instance.updatePurchase(purchase);
                          }

                          if (!context.mounted) return;

                          Navigator.pop(context);

                          if (mounted) {
                            await _loadPurchases();
                          }
                        },
                  child: Text(
                    existingPurchase == null ? 'Save' : 'Update',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase History')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Purchase History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Total Spent: \$0.00'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Purchases',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_list),
                    SizedBox(width: 8),
                    Text('Filter'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            if (_purchases.isEmpty)
              const Text('No purchases recorded yet.')
            else
              ..._purchases.map((purchase) {
                final matchingMeals = _meals.where(
                  (meal) => meal.id == purchase.mealId,
                );

                final mealName = matchingMeals.isNotEmpty
                    ? matchingMeals.first.name
                    : 'Deleted Meal';

                return Card(
                  child: ListTile(
                    title: Text(mealName),
                    subtitle: Text(
                      'Date: ${purchase.purchasedAt.month}/${purchase.purchasedAt.day}/${purchase.purchasedAt.year}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${(purchase.actualPriceMinor / 100).toStringAsFixed(2)}',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Edit Purchase',
                          onPressed: () => _showPurchaseDialog(
                            existingPurchase: purchase,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 32),

            OutlinedButton(
              onPressed: () => _showPurchaseDialog(),
              child: const Text('Add Purchase'),
            ),
          ],
        ),
      ),
    );
  }
}
