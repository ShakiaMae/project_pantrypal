import 'package:flutter/material.dart';
import '../../model/recipe.dart';
import '../../services/storage_service.dart';
import 'recipe_detail_screen.dart';

class RecipeBrowserScreen extends StatefulWidget {
  const RecipeBrowserScreen({super.key});

  @override
  State<RecipeBrowserScreen> createState() => _RecipeBrowserScreenState();
}

class _RecipeBrowserScreenState extends State<RecipeBrowserScreen> {
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Italian', 'Asian', 'Dessert', 'Custom'];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final recipes = await StorageService.getRecipes();
    if (mounted) {
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    }
  }

  List<Recipe> get _filteredRecipes {
    if (_selectedCategory == 'All') {
      return _recipes;
    }
    return _recipes.where((recipe) => recipe.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecipes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_recipes.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Category Filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  selectedColor: const Color(0xFFFF6B35).withOpacity(0.2),
                  checkmarkColor: const Color(0xFFFF6B35),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Recipes List
        Expanded(
          child: _filteredRecipes.isEmpty
              ? _buildNoRecipesForCategory()
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = _filteredRecipes[index];
              return _buildRecipeCard(recipe);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No recipes available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first custom recipe to get started!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoRecipesForCategory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No recipes in $_selectedCategory category',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different category or add a new recipe!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                recipe.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.restaurant,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            // Recipe Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipe.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (recipe.isCustom)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Custom',
                            style: TextStyle(
                              color: const Color(0xFFFF6B35),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Recipe Stats
                  Row(
                    children: [
                      _buildStatChip(Icons.access_time, '${recipe.prepTime} min prep'),
                      const SizedBox(width: 8),
                      _buildStatChip(Icons.schedule, '${recipe.cookTime} min cook'),
                      const SizedBox(width: 8),
                      _buildStatChip(Icons.people, '${recipe.servings} servings'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Ingredients Preview
                  Text(
                    'Ingredients: ${recipe.ingredients.length} items',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
