import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../model/ingredient.dart';
import '../../services/storage_service.dart';

class AddIngredientScreen extends StatefulWidget {
  final Ingredient? ingredient;

  const AddIngredientScreen({super.key, this.ingredient});

  @override
  State<AddIngredientScreen> createState() => _AddIngredientScreenState();
}

class _AddIngredientScreenState extends State<AddIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _expiryDateController = TextEditingController();

  DateTime? _expiryDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.ingredient != null) {
      _nameController.text = widget.ingredient!.name;
      _quantityController.text = widget.ingredient!.quantity.toString();
      _unitController.text = widget.ingredient!.unit;
      if (widget.ingredient!.expiryDate != null) {
        _expiryDate = widget.ingredient!.expiryDate;
        _expiryDateController.text = _formatDate(widget.ingredient!.expiryDate!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _expiryDate = date;
        _expiryDateController.text = _formatDate(date);
      });
    }
  }

  Future<void> _saveIngredient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final ingredient = Ingredient(
        id: widget.ingredient?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        quantity: double.parse(_quantityController.text),
        unit: _unitController.text.trim(),
        addedDate: widget.ingredient?.addedDate ?? DateTime.now(),
        expiryDate: _expiryDate,
      );

      if (widget.ingredient != null) {
        await StorageService.updateIngredient(ingredient);
      } else {
        await StorageService.addIngredient(ingredient);
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
        title: Text(widget.ingredient != null ? 'Edit Ingredient' : 'Add Ingredient'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveIngredient,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ingredient Name',
                  hintText: 'e.g., Chicken Breast, Tomatoes, Flour',
                  prefixIcon: Icon(Icons.kitchen),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter ingredient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quantity and Unit Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        hintText: '1.5',
                        prefixIcon: Icon(Icons.scale),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        hintText: 'kg, g, pieces',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Expiry Date Field
              TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date (Optional)',
                  hintText: 'Select expiry date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: _selectExpiryDate,
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveIngredient,
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
                  widget.ingredient != null ? 'Update Ingredient' : 'Add Ingredient',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
