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
  final List<String> _categories = [
    'Custom', 'Italian', 'Asian', 'Dessert', 'Mexican', 'American'
  ];

  List<RecipeIngredient> _ingredients = [];
  List<TextEditingController> _ingredientControllers = [];
  List<TextEditingController> _ingredientQtyControllers = [];
  List<TextEditingController> _ingredientUnitControllers = [];

  List<String> _instructions = [];
  List<TextEditingController> _instructionControllers = [];

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

      for (var ing in _ingredients) {
        _ingredientControllers.add(TextEditingController(text: ing.name));
        _ingredientQtyControllers.add(TextEditingController(text: ing.quantity.toString()));
        _ingredientUnitControllers.add(TextEditingController(text: ing.unit));
      }

      for (var instr in _instructions) {
        _instructionControllers.add(TextEditingController(text: instr));
      }
    } else {
      _addIngredientField();
      _addInstructionField();
    }
  }

  void _addIngredientField() {
    _ingredients.add(RecipeIngredient(name: '', quantity: 0, unit: ''));
    _ingredientControllers.add(TextEditingController());
    _ingredientQtyControllers.add(TextEditingController());
    _ingredientUnitControllers.add(TextEditingController());
  }

  void _addInstructionField() {
    _instructions.add('');
    _instructionControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    for (var c in _ingredientControllers) c.dispose();
    for (var c in _ingredientQtyControllers) c.dispose();
    for (var c in _ingredientUnitControllers) c.dispose();
    for (var c in _instructionControllers) c.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    for (int i = 0; i < _ingredients.length; i++) {
      _ingredients[i] = RecipeIngredient(
        name: _ingredientControllers[i].text.trim(),
        quantity: double.tryParse(_ingredientQtyControllers[i].text.trim()) ?? 0,
        unit: _ingredientUnitControllers[i].text.trim(),
      );
    }

    for (int i = 0; i < _instructions.length; i++) {
      _instructions[i] = _instructionControllers[i].text.trim();
    }

    if (_ingredients.isEmpty || _ingredients.every((i) => i.name.isEmpty) ||
        _instructions.isEmpty || _instructions.every((i) => i.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient and instruction.')),
      );
      return;
    }

    setState(() => _isLoading = true);

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

      if (mounted) Navigator.of(context).pop(recipe);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error saving recipe: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFFEB35FF),
      fontSize: 18,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      appBar: AppBar(
        title: Text(widget.recipe != null ? 'Edit Recipe' : 'Add Recipe'),
        backgroundColor: Colors.transparent, // Make the AppBar transparent
        elevation: 0, // Remove the elevation to avoid the large rectangle
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveRecipe,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Save', style: TextStyle(color: Colors.white)),
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
              _buildSectionTitle('Basic Info'),
              const SizedBox(height: 12),
              _inputField(_titleController, 'Title', validator: (v) => v == null || v.trim().isEmpty ? 'Enter title' : null),
              const SizedBox(height: 12),
              _inputField(_descriptionController, 'Description', maxLines: 3, validator: (v) => v == null || v.trim().isEmpty ? 'Enter description' : null),
              const SizedBox(height: 12),
              _inputField(_imageUrlController, 'Image URL (Optional)'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _decoration('Category'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Details'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _inputField(_prepTimeController, 'Prep Time (min)', keyboardType: TextInputType.number, validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid' : null)),
                  const SizedBox(width: 12),
                  Expanded(child: _inputField(_cookTimeController, 'Cook Time (min)', keyboardType: TextInputType.number, validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid' : null)),
                ],
              ),
              const SizedBox(height: 12),
              _inputField(_servingsController, 'Servings', keyboardType: TextInputType.number, validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid' : null),
              const SizedBox(height: 20),
              _buildIngredientsUI(),
              const SizedBox(height: 20),
              _buildInstructionsUI(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEB35FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.recipe != null ? 'Update Recipe' : 'Add Recipe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String label, {int maxLines = 1, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(label),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      labelStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Color(0xFFEB35FF), width: 1.4),
      ),
    );
  }

  Widget _buildIngredientsUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...List.generate(_ingredients.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(flex: 2, child: _inputField(_ingredientControllers[index], 'Ingredient')),
                const SizedBox(width: 8),
                Expanded(flex: 1, child: _inputField(_ingredientQtyControllers[index], 'Qty', keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(flex: 1, child: _inputField(_ingredientUnitControllers[index], 'Unit')),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() {
                    _ingredients.removeAt(index);
                    _ingredientControllers.removeAt(index);
                    _ingredientQtyControllers.removeAt(index);
                    _ingredientUnitControllers.removeAt(index);
                  }),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInstructionsUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...List.generate(_instructions.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: Color(0xFFEB35FF), shape: BoxShape.circle),
                  child: Center(
                    child: Text('${index + 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _inputField(_instructionControllers[index], 'Instruction', maxLines: 3),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() {
                    _instructions.removeAt(index);
                    _instructionControllers.removeAt(index);
                  }),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
