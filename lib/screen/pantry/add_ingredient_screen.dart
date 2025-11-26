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
        _expiryDateController.text = _formatDate(_expiryDate!);
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

  String _formatDate(DateTime date) =>
      "${date.day}/${date.month}/${date.year}";

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFEB35FF), // neon accent
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A1C),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF141414),
          ),
          child: child!,
        );
      },
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

    setState(() => _isLoading = true);

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

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // no glow, flat & neon accent
  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEB35FF), width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.ingredient != null ? "Edit Ingredient" : "Add Ingredient",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveIngredient,
            child: _isLoading
                ? const SizedBox(
              width: 18,
              height: 18,
              child:
              CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : const Text(
              "Save",
              style: TextStyle(fontSize: 18, color: Color(0xFFEB35FF)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Ingredient Name", Icons.kitchen),
                style: const TextStyle(color: Colors.white),
                validator: (value) =>
                value == null || value.trim().isEmpty ? "Please enter name" : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Quantity", Icons.scale),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return "Required";
                        if (double.tryParse(value) == null) return "Invalid number";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: _inputDecoration("Unit", null),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                      value == null || value.trim().isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _expiryDateController,
                readOnly: true,
                onTap: _selectExpiryDate,
                decoration:
                _inputDecoration("Expiry Date (Optional)", Icons.calendar_today),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveIngredient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEB35FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    widget.ingredient != null
                        ? "Update Ingredient"
                        : "Add Ingredient",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
