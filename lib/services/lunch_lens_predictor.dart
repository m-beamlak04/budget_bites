import '../models/purchase_log.dart';

class LunchLensPredictor {
  // Filters valid purchase records for the selected meal
  static List<PurchaseLog> getMealPurchases(
    int mealId,
    List<PurchaseLog> purchases,
  ) {
    return purchases
        .where(
          (purchase) =>
              purchase.mealId == mealId && purchase.actualPriceMinor > 0,
        )
        .toList();
  }

  // Predicts a meal's price using the average of its three most recent purchases
  static int? predictPrice(int mealId, List<PurchaseLog> purchases) {
    final mealPurchases = getMealPurchases(mealId, purchases);

    if (mealPurchases.length < 3) {
      return null;
    }

    final recentThree = mealPurchases.take(3);

    final total = recentThree.fold<int>(
      0,
      (sum, purchase) => sum + purchase.actualPriceMinor,
    );

    return (total / 3).round();
  }

  // Returns the most recent recorded price for the selected meal
  static int? baselinePrice(int mealId, List<PurchaseLog> purchases) {
    final mealPurchases = getMealPurchases(mealId, purchases);

    if (mealPurchases.isEmpty) {
      return null;
    }

    return mealPurchases.first.actualPriceMinor;
  }
}
