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
        title: const Text('Delete Ingredient'),
        content: Text('Are you sure you want to delete ${ingredient.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadIngredients,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ingredients.isEmpty
          ? _buildEmptyState()
          : _buildIngredientsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddIngredientScreen(),
            ),
          );
          if (result == true) {
            _loadIngredients();
          }
        },
        backgroundColor: const Color(0xFFFF6B35),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.kitchen_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Your pantry is empty',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some ingredients to get started!',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddIngredientScreen(),
                  ),
                );
                if (result == true) {
                  _loadIngredients();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add First Ingredient'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = _ingredients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFF6B35).withOpacity(0.1),
              child: Icon(
                _getIngredientIcon(ingredient.name),
                color: const Color(0xFFFF6B35),
              ),
            ),
            title: Text(
              ingredient.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${ingredient.quantity} ${ingredient.unit}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: PopupMenuButton(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteIngredient(ingredient);
                } else if (value == 'edit') {
                  _editIngredient(ingredient);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
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
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddIngredientScreen(ingredient: ingredient),
      ),
    );
    if (result == true) {
      _loadIngredients();
    }
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
