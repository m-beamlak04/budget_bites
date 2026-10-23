class PurchaseLog {
  final int? id;
  final int mealId;
  final DateTime purchasedAt;
  final int actualPriceMinor;

  PurchaseLog({
    this.id,
    required this.mealId,
    required this.purchasedAt,
    required this.actualPriceMinor,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'mealId': mealId,
      'purchasedAt': purchasedAt.toIso8601String(),
      'actualPriceMinor': actualPriceMinor,
    };
  }

  factory PurchaseLog.fromMap(Map<String, Object?> map) {
    return PurchaseLog(
      id: map['id'] as int?,
      mealId: map['mealId'] as int,
      purchasedAt: DateTime.parse(map['purchasedAt'] as String),
      actualPriceMinor: map['actualPriceMinor'] as int,
    );
  }
}