import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../model/recipe.dart';
import '../../services/storage_service.dart';
import 'add_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback? onDelete;

  const RecipeDetailScreen({Key? key, required this.recipe, this.onDelete}) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int currentStep = 0;

  // Neon Pink color defined without const keyword
  final Color neonPink = Color(0xFFFF6B35);

  void nextStep() {
    if (currentStep < widget.recipe.instructions.length - 1) {
      setState(() => currentStep++);
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  void deleteRecipe() {
    if (widget.onDelete != null) widget.onDelete!();
    Navigator.of(context).pop(true); // return true to indicate deletion
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              deleteRecipe();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        backgroundColor: Colors.transparent, // Transparent background
        elevation: 0, // Remove the pink elevation bar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              recipe.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 250,
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, size: 50),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title & Description
          Text(
            recipe.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: neonPink, // Apply neon pink to title text
            ),
          ),
          const SizedBox(height: 8),
          Text(
            recipe.description,
            style: TextStyle(color: Colors.grey[700], height: 1.4),
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(children: [
                Icon(Icons.schedule, color: neonPink), // Apply neon pink to icon
                const SizedBox(height: 4),
                Text('${recipe.prepTime} min', style: TextStyle(fontWeight: FontWeight.bold, color: neonPink)),
                const Text('Prep', style: TextStyle(color: Colors.grey)),
              ]),
              Column(children: [
                Icon(Icons.local_fire_department, color: neonPink),
                const SizedBox(height: 4),
                Text('${recipe.cookTime} min', style: TextStyle(fontWeight: FontWeight.bold, color: neonPink)),
                const Text('Cook', style: TextStyle(color: Colors.grey)),
              ]),
              Column(children: [
                Icon(Icons.restaurant_menu, color: neonPink),
                const SizedBox(height: 4),
                Text('${recipe.servings}', style: TextStyle(fontWeight: FontWeight.bold, color: neonPink)),
                const Text('Servings', style: TextStyle(color: Colors.grey)),
              ]),
            ],
          ),
          const SizedBox(height: 24),

          // Ingredients
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ExpansionTile(
              title: Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: neonPink),
              ),
              children: recipe.ingredients
                  .where((ingredient) => ingredient.name.isNotEmpty)
                  .map((ingredient) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(fontSize: 18, color: neonPink)), // Neon pink
                    Expanded(
                      child: Text(
                        '${ingredient.quantity > 0 ? ingredient.quantity : ''} '
                            '${ingredient.unit.isNotEmpty ? ingredient.unit : ''} '
                            '${ingredient.name}',
                        style: TextStyle(color: Colors.grey[800], fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Instructions
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Instructions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: neonPink),
                ),
                const SizedBox(height: 16),
                Text('Step ${currentStep + 1} of ${recipe.instructions.length}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: neonPink)),
                const SizedBox(height: 8),
                Text(recipe.instructions[currentStep],
                    style: TextStyle(color: Colors.grey[800], fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: currentStep > 0 ? previousStep : null,
                      style: ElevatedButton.styleFrom(backgroundColor: neonPink),
                      child: const Text('Previous'),
                    ),
                    ElevatedButton(
                      onPressed: currentStep < recipe.instructions.length - 1 ? nextStep : null,
                      style: ElevatedButton.styleFrom(backgroundColor: neonPink),
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // Category
          Text('Category: ${recipe.category}', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),

          // Edit & Delete Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddRecipeScreen(recipe: widget.recipe),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: neonPink),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: showDeleteDialog,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ]), // End of Column
      ),
    );
  }
}
