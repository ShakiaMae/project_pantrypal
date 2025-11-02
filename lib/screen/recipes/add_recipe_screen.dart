import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../model/recipe.dart';
import '../../services/storage_service.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? recipe;

  const AddRecipeScreen({super.key, this.recipe});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  String _selectedCategory = 'Custom';
  final List<String> _categories = ['Custom', 'Italian', 'Asian', 'Dessert', 'Mexican', 'American'];

  List<RecipeIngredient> _ingredients = [];
  List<String> _instructions = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _titleController.text = widget.recipe!.title;
      _descriptionController.text = widget.recipe!.description;
      _imageUrlController.text = widget.recipe!.imageUrl;
      _prepTimeController.text = widget.recipe!.prepTime.toString();
      _cookTimeController.text = widget.recipe!.cookTime.toString();
      _servingsController.text = widget.recipe!.servings.toString();
      _selectedCategory = widget.recipe!.category;
      _ingredients = List.from(widget.recipe!.ingredients);
      _instructions = List.from(widget.recipe!.instructions);
    } else {
      _ingredients.add(RecipeIngredient(name: '', quantity: 0, unit: ''));
      _instructions.add('');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty || _instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient and instruction')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final recipe = Recipe(
        id: widget.recipe?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400'
            : _imageUrlController.text.trim(),
        ingredients: _ingredients.where((i) => i.name.isNotEmpty).toList(),
        instructions: _instructions.where((i) => i.isNotEmpty).toList(),
        prepTime: int.parse(_prepTimeController.text),
        cookTime: int.parse(_cookTimeController.text),
        servings: int.parse(_servingsController.text),
        category: _selectedCategory,
        isCustom: true,
      );

      if (widget.recipe != null) {
        await StorageService.updateRecipe(recipe);
      } else {
        await StorageService.addRecipe(recipe);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe != null ? 'Edit Recipe' : 'Add Custom Recipe'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveRecipe,
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info Section
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter recipe title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter recipe description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                  hintText: 'https://example.com/image.jpg',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Recipe Stats Section
              _buildSectionTitle('Recipe Details'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prepTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prep Time (min)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cookTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cook Time (min)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _servingsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Servings',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter number of servings';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Ingredients Section
              _buildIngredientsSection(),
              const SizedBox(height: 32),

              // Instructions Section
              _buildInstructionsSection(),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    widget.recipe != null ? 'Update Recipe' : 'Add Recipe',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(0xFFFF6B35),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Ingredients'),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _ingredients.add(RecipeIngredient(name: '', quantity: 0, unit: ''));
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Ingredient'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._ingredients.asMap().entries.map((entry) {
          final index = entry.key;
          final ingredient = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: ingredient.name,
                        decoration: const InputDecoration(
                          labelText: 'Ingredient Name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _ingredients[index] = RecipeIngredient(
                            name: value,
                            quantity: ingredient.quantity,
                            unit: ingredient.unit,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: ingredient.quantity.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Qty',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _ingredients[index] = RecipeIngredient(
                            name: ingredient.name,
                            quantity: double.tryParse(value) ?? 0,
                            unit: ingredient.unit,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: ingredient.unit,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _ingredients[index] = RecipeIngredient(
                            name: ingredient.name,
                            quantity: ingredient.quantity,
                            unit: value,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _ingredients.removeAt(index);
                        });
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Instructions'),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _instructions.add('');
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Step'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._instructions.asMap().entries.map((entry) {
          final index = entry.key;
          final instruction = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B35),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: instruction,
                    decoration: const InputDecoration(
                      labelText: 'Instruction',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      _instructions[index] = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _instructions.removeAt(index);
                    });
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
