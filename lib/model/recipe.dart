class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final int prepTime; // in minutes
  final int cookTime; // in minutes
  final int servings;
  final String category;
  final bool isCustom;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.category,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'instructions': instructions,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'category': category,
      'isCustom': isCustom,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      ingredients: (json['ingredients'] as List)
          .map((i) => RecipeIngredient.fromJson(i))
          .toList(),
      instructions: List<String>.from(json['instructions']),
      prepTime: json['prepTime'],
      cookTime: json['cookTime'],
      servings: json['servings'],
      category: json['category'],
      isCustom: json['isCustom'] ?? false,
    );
  }
}

class RecipeIngredient {
  final String name;
  final double quantity;
  final String unit;

  RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
    );
  }
}
