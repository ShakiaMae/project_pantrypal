class Ingredient {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final DateTime addedDate;
  final DateTime? expiryDate;

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.addedDate,
    this.expiryDate,
  });

  /// Convert Ingredient object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'addedDate': addedDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }

  /// Create Ingredient object from JSON
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      addedDate: DateTime.parse(json['addedDate'] as String),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
    );
  }

  /// Copy the Ingredient with optional new values
  Ingredient copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    DateTime? addedDate,
    DateTime? expiryDate,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      addedDate: addedDate ?? this.addedDate,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  @override
  String toString() {
    return 'Ingredient(id: $id, name: $name, quantity: $quantity $unit, addedDate: $addedDate, expiryDate: $expiryDate)';
  }
}
