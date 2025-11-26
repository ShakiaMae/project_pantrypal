import 'package:flutter/material.dart';
import '../../model/recipe.dart';
import '../../services/storage_service.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';
import '../../widgets/loading_overlay.dart';

class RecipeBrowserScreen extends StatefulWidget {
  const RecipeBrowserScreen({super.key});

  @override
  State<RecipeBrowserScreen> createState() => _RecipeBrowserScreenState();
}

class _RecipeBrowserScreenState extends State<RecipeBrowserScreen> {
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All', 'Italian', 'Asian', 'Dessert', 'Custom'
  ];

  // Neon Colors (NO GLOW)
  final Color neonPink = const Color(0xFFFF0DF5);
  final Color bgDark = const Color(0xFF0C0C0C);
  final Color cardDark = const Color(0xFF161616);

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() => _isLoading = true);
    final recipes = await StorageService.getRecipes();
    if (mounted) {
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToAddRecipe() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
    );

    if (result == true) {
      await _loadRecipes();
    }
  }

  List<Recipe> get _filteredRecipes {
    if (_selectedCategory == 'All') return _recipes;
    return _recipes.where((r) => r.category == _selectedCategory).toList();
  }

  void _deleteRecipe(Recipe recipe) {
    setState(() => _recipes.remove(recipe));
    StorageService.saveRecipes(_recipes);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: bgDark,
        appBar: AppBar(
          backgroundColor: bgDark,
          elevation: 0,
          iconTheme: IconThemeData(color: neonPink),
          title: Text(
            "Recipes",
            style: TextStyle(
              color: neonPink,
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: neonPink),
              onPressed: _loadRecipes,
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: neonPink,
          child: const Icon(Icons.add, color: Colors.black),
          onPressed: _navigateToAddRecipe,
        ),
        body: _buildContent(),
      ),
    );
  }

  // CATEGORY CHIPS
  Widget _buildContent() {
    if (_recipes.isEmpty) return _buildEmptyState();

    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, i) {
              final c = _categories[i];
              final selected = c == _selectedCategory;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(
                    c,
                    style: TextStyle(
                      color:
                      selected ? Colors.black : neonPink.withOpacity(.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: selected,
                  selectedColor: neonPink,
                  backgroundColor: const Color(0xFF1F1F1F),
                  onSelected: (_) => setState(() => _selectedCategory = c),
                  side: BorderSide(
                    color: selected ? neonPink : Colors.grey[800]!,
                    width: 1.2,
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _filteredRecipes.isEmpty
              ? _buildNoRecipesForCategory()
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredRecipes.length,
            itemBuilder: (c, i) =>
                _buildRecipeCard(_filteredRecipes[i]),
          ),
        )
      ],
    );
  }

  // CARD UI — CLEAN, NO GLOW
  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: neonPink.withOpacity(0.15),
          width: 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final deleted = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(
                recipe: recipe,
                onDelete: () => _deleteRecipe(recipe),
              ),
            ),
          );

          if (deleted == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${recipe.title} deleted')),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                recipe.imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.black,
                  child: Icon(Icons.restaurant, size: 50, color: neonPink),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titleRow(recipe),
                  const SizedBox(height: 8),
                  Text(
                    recipe.description,
                    style: TextStyle(
                      color: Colors.grey[400],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _statChip(Icons.access_time, '${recipe.prepTime} min'),
                      const SizedBox(width: 10),
                      _statChip(Icons.schedule, '${recipe.cookTime} min'),
                      const SizedBox(width: 10),
                      _statChip(Icons.people, '${recipe.servings} servings'),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _titleRow(Recipe recipe) {
    return Row(
      children: [
        Expanded(
          child: Text(
            recipe.title,
            style: TextStyle(
              color: neonPink,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (recipe.isCustom)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: neonPink.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Custom",
              style: TextStyle(
                color: neonPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
      ],
    );
  }

  // CLEAN STAT CHIP — NO GLOW
  Widget _statChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: neonPink.withOpacity(.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: neonPink),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: neonPink, fontSize: 12)),
        ],
      ),
    );
  }

  // EMPTY STATES
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 80, color: neonPink.withOpacity(.4)),
          const SizedBox(height: 20),
          Text(
            "No recipes yet",
            style: TextStyle(
              fontSize: 22,
              color: neonPink,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text("Tap + to add your first recipe!",
              style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildNoRecipesForCategory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_alt_off,
              size: 80, color: neonPink.withOpacity(.4)),
          const SizedBox(height: 20),
          Text(
            "No recipes in $_selectedCategory",
            style: TextStyle(
              color: neonPink,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try another filter or add a recipe.",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
