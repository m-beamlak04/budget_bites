// Represents a meal with its details and estimated price
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

  // Converts a Meal object into a map for storing in the database
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'cuisine': cuisine,
      'venue': venue,
      'estimated_price': estimatedPrice,
    };
  }

  // Creates a Meal object from data retrieved from the database
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
