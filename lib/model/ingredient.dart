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

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      addedDate: DateTime.parse(json['addedDate']),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
    );
  }

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
}
