import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/ingredient.dart';
import '../model/recipe.dart';
import '../model/user.dart';

class StorageService {
  static const String _userKey = 'user';
  static const String _ingredientsKey = 'ingredients';
  static const String _recipesKey = 'recipes';

  // User methods
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setBool('isLoggedIn', true);
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  static Future<bool> validateUser(String email, String password) async {
    final user = await getUser();
    if (user == null) {
      return false;
    }
    final isValid = user.email.toLowerCase() == email.toLowerCase() &&
        user.password == password;

    if (isValid) {
      // Set login status when credentials are valid
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
    }

    return isValid;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool('isLoggedIn', false);
  }

  // Ingredient methods
  static Future<List<Ingredient>> getIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    final ingredientsJson = prefs.getString(_ingredientsKey);
    if (ingredientsJson != null) {
      final List<dynamic> ingredientsList = jsonDecode(ingredientsJson);
      return ingredientsList.map((json) => Ingredient.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> saveIngredients(List<Ingredient> ingredients) async {
    final prefs = await SharedPreferences.getInstance();
    final ingredientsJson =
    jsonEncode(ingredients.map((i) => i.toJson()).toList());
    await prefs.setString(_ingredientsKey, ingredientsJson);
  }

  static Future<void> addIngredient(Ingredient ingredient) async {
    final ingredients = await getIngredients();
    ingredients.add(ingredient);
    await saveIngredients(ingredients);
  }

  static Future<void> updateIngredient(Ingredient ingredient) async {
    final ingredients = await getIngredients();
    final index = ingredients.indexWhere((i) => i.id == ingredient.id);
    if (index != -1) {
      ingredients[index] = ingredient;
      await saveIngredients(ingredients);
    }
  }

  static Future<void> deleteIngredient(String ingredientId) async {
    final ingredients = await getIngredients();
    ingredients.removeWhere((i) => i.id == ingredientId);
    await saveIngredients(ingredients);
  }

  // Recipe methods
  static Future<List<Recipe>> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getString(_recipesKey);
    if (recipesJson != null) {
      final List<dynamic> recipesList = jsonDecode(recipesJson);
      return recipesList.map((json) => Recipe.fromJson(json)).toList();
    }
    return _getDefaultRecipes();
  }

  static Future<void> saveRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = jsonEncode(recipes.map((r) => r.toJson()).toList());
    await prefs.setString(_recipesKey, recipesJson);
  }

  static Future<void> addRecipe(Recipe recipe) async {
    final recipes = await getRecipes();
    recipes.add(recipe);
    await saveRecipes(recipes);
  }

  static Future<void> updateRecipe(Recipe recipe) async {
    final recipes = await getRecipes();
    final index = recipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      recipes[index] = recipe;
      await saveRecipes(recipes);
    }
  }

  static Future<void> deleteRecipe(String recipeId) async {
    final recipes = await getRecipes();
    recipes.removeWhere((r) => r.id == recipeId);
    await saveRecipes(recipes);
  }

  static List<Recipe> _getDefaultRecipes() {
    return [
      Recipe(
        id: '1',
        title: 'Classic Spaghetti Carbonara',
        description:
        'A creamy Italian pasta dish with eggs, cheese, and pancetta',
        imageUrl:
        'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400',
        ingredients: [
          RecipeIngredient(name: 'Spaghetti', quantity: 400, unit: 'g'),
          RecipeIngredient(name: 'Eggs', quantity: 4, unit: 'pieces'),
          RecipeIngredient(name: 'Parmesan Cheese', quantity: 100, unit: 'g'),
          RecipeIngredient(name: 'Pancetta', quantity: 150, unit: 'g'),
          RecipeIngredient(name: 'Black Pepper', quantity: 1, unit: 'tsp'),
        ],
        instructions: [
          'Cook spaghetti according to package directions',
          'Cut pancetta into small cubes and cook until crispy',
          'Beat eggs with grated parmesan and black pepper',
          'Drain pasta and mix with pancetta',
          'Remove from heat and quickly mix in egg mixture',
          'Serve immediately with extra parmesan'
        ],
        prepTime: 10,
        cookTime: 15,
        servings: 4,
        category: 'Italian',
      ),
      Recipe(
        id: '2',
        title: 'Chicken Stir Fry',
        description: 'Quick and healthy chicken stir fry with vegetables',
        imageUrl:
        'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400',
        ingredients: [
          RecipeIngredient(name: 'Chicken Breast', quantity: 500, unit: 'g'),
          RecipeIngredient(name: 'Bell Peppers', quantity: 2, unit: 'pieces'),
          RecipeIngredient(name: 'Broccoli', quantity: 200, unit: 'g'),
          RecipeIngredient(name: 'Soy Sauce', quantity: 3, unit: 'tbsp'),
          RecipeIngredient(name: 'Garlic', quantity: 3, unit: 'cloves'),
          RecipeIngredient(name: 'Ginger', quantity: 1, unit: 'tbsp'),
        ],
        instructions: [
          'Cut chicken into bite-sized pieces',
          'Heat oil in a large pan or wok',
          'Cook chicken until golden brown',
          'Add vegetables and stir fry for 3-4 minutes',
          'Add garlic and ginger, cook for 1 minute',
          'Add soy sauce and toss everything together',
          'Serve over rice'
        ],
        prepTime: 15,
        cookTime: 10,
        servings: 4,
        category: 'Asian',
      ),
      Recipe(
        id: '3',
        title: 'Chocolate Chip Cookies',
        description: 'Soft and chewy homemade chocolate chip cookies',
        imageUrl:
        'https://images.unsplash.com/photo-1499636136210-6f4ee6afc8c9?w=400',
        ingredients: [
          RecipeIngredient(name: 'All-Purpose Flour', quantity: 250, unit: 'g'),
          RecipeIngredient(name: 'Butter', quantity: 115, unit: 'g'),
          RecipeIngredient(name: 'Brown Sugar', quantity: 100, unit: 'g'),
          RecipeIngredient(name: 'White Sugar', quantity: 50, unit: 'g'),
          RecipeIngredient(name: 'Eggs', quantity: 1, unit: 'piece'),
          RecipeIngredient(name: 'Chocolate Chips', quantity: 200, unit: 'g'),
          RecipeIngredient(name: 'Vanilla Extract', quantity: 1, unit: 'tsp'),
        ],
        instructions: [
          'Preheat oven to 350°F (175°C)',
          'Cream butter and sugars together',
          'Beat in egg and vanilla',
          'Mix in flour gradually',
          'Fold in chocolate chips',
          'Drop rounded tablespoons onto baking sheet',
          'Bake for 9-11 minutes until golden',
          'Cool on baking sheet for 2 minutes'
        ],
        prepTime: 15,
        cookTime: 11,
        servings: 24,
        category: 'Dessert',
      ),
    ];
  }
}
