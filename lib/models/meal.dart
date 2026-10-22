class Meal {
  final int? id;
  final String name;
  final String cuisine;
  final String venue;
  final double estimatedPrice;

  Meal({
    this.id,
    required this.name,
    required this.cuisine,
    required this.venue,
    required this.estimatedPrice,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'cuisine': cuisine,
      'venue': venue,
      'estimated_price': estimatedPrice,
    };
  }

  factory Meal.fromMap(Map<String, Object?> map) {
    return Meal(
      id: map['id'] as int?,
      name: map['name'] as String,
      cuisine: map['cuisine'] as String,
      venue: map['venue'] as String,
      estimatedPrice: (map['estimated_price'] as num).toDouble(),
    );
  }
}
