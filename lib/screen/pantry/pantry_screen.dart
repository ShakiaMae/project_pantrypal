import 'package:flutter/material.dart';

import '../../model/ingredient.dart';
import '../../services/storage_service.dart';
import 'add_ingredient_screen.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  List<Ingredient> _ingredients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    final ingredients = await StorageService.getIngredients();
    if (mounted) {
      setState(() {
        _ingredients = ingredients;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteIngredient(Ingredient ingredient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Ingredient', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${ingredient.name}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.deleteIngredient(ingredient.id);
      _loadIngredients();
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF0C0C0C);
    const neonPink = Color(0xFFFF0DF5);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Pantry',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadIngredients,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: neonPink))
          : _ingredients.isEmpty
          ? _buildEmptyState()
          : _buildIngredientsList(),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddIngredientScreen(),
            ),
          );
          if (result == true) _loadIngredients();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: neonPink,
        elevation: 0, // ← flat style
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // EMPTY STATE
  // -------------------------------------------------------------------------
  Widget _buildEmptyState() {
    const neonPink = Color(0xFFFF0DF5);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.kitchen, size: 100, color: Colors.white24),
            const SizedBox(height: 24),
            const Text(
              'Your pantry is empty',
              style: TextStyle(fontSize: 24, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add some ingredients to get started!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddIngredientScreen()),
                );
                if (result == true) _loadIngredients();
              },
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text('Add First Ingredient', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: neonPink,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // INGREDIENT LIST
  // -------------------------------------------------------------------------
  Widget _buildIngredientsList() {
    const neonPink = Color(0xFFFF0DF5);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = _ingredients[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: neonPink.withOpacity(0.15),
              child: Icon(_getIngredientIcon(ingredient.name), color: neonPink),
            ),
            title: Text(
              ingredient.name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
            ),
            subtitle: Text(
              '${ingredient.quantity} ${ingredient.unit}',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            trailing: PopupMenuButton(
              color: const Color(0xFF1B1C1E),
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              onSelected: (value) {
                if (value == 'edit') _editIngredient(ingredient);
                if (value == 'delete') _deleteIngredient(ingredient);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Text('Edit', style: TextStyle(color: Colors.white)),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete, color: Colors.redAccent, size: 20),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.redAccent)),
                  ]),
                ),
              ],
            ),
            onTap: () => _editIngredient(ingredient),
          ),
        );
      },
    );
  }

  void _editIngredient(Ingredient ingredient) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddIngredientScreen(ingredient: ingredient),
      ),
    );
    if (result == true) _loadIngredients();
  }

  IconData _getIngredientIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('chicken') || lowerName.contains('meat')) {
      return Icons.restaurant;
    } else if (lowerName.contains('vegetable') ||
        lowerName.contains('carrot') ||
        lowerName.contains('onion')) {
      return Icons.eco;
    } else if (lowerName.contains('milk') ||
        lowerName.contains('cheese') ||
        lowerName.contains('yogurt')) {
      return Icons.local_drink;
    } else if (lowerName.contains('bread') ||
        lowerName.contains('flour') ||
        lowerName.contains('pasta')) {
      return Icons.grain;
    } else if (lowerName.contains('fruit') ||
        lowerName.contains('apple') ||
        lowerName.contains('banana')) {
      return Icons.apple;
    } else {
      return Icons.kitchen;
    }
  }
}
