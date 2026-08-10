import 'package:flutter/material.dart';

import '../../categories/models/category.dart';
import '../../categories/services/category_service.dart';
import '../../layout/screens/app_shell.dart';
import '../services/product_service.dart';

class ProductFormScreen extends StatefulWidget {
  final int? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  final _productService = ProductService();
  final _categoryService = CategoryService();

  final _formKey = GlobalKey<FormState>();
  bool get _isEditMode => widget.productId != null;

  late Future<List<Category>> _categories;

  int? _selectedCategoryId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _categories = _categoryService.getCategories();

    if (_isEditMode) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    final product = await _productService.getProduct(widget.productId!);

    _nameController.text = product.name;
    _unitController.text = product.unit;
    _priceController.text = product.sellingPrice.toString();
    _quantityController.text = product.quantity.toString();

    setState(() {
      _selectedCategoryId = product.categoryId;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEditMode) {
        await _productService.updateProduct(
          id: widget.productId!,
          name: _nameController.text.trim(),
          unit: _unitController.text.trim(),
          sellingPrice: double.parse(_priceController.text),
          quantity: int.parse(_quantityController.text),
          categoryId: _selectedCategoryId!,
        );
      } else {
        await _productService.createProduct(
          name: _nameController.text.trim(),
          unit: _unitController.text.trim(),
          sellingPrice: double.parse(_priceController.text),
          quantity: int.parse(_quantityController.text),
          categoryId: _selectedCategoryId!,
        );
      }
      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to create product')));

      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 500,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isEditMode ? 'Edit Product' : 'New Product',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 30),

                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter a product name';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _unitController,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            hintText: 'piece, kg, liter...',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter a unit';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Selling Price',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter a selling price';
                            }

                            final price = double.tryParse(value);

                            if (price == null || price < 0) {
                              return 'Enter a valid price';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter a quantity';
                            }

                            final quantity = int.tryParse(value);

                            if (quantity == null || quantity < 0) {
                              return 'Enter a valid quantity';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        FutureBuilder<List<Category>>(
                          future: _categories,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const LinearProgressIndicator();
                            }

                            if (snapshot.hasError) {
                              return const Text('Failed to load categories');
                            }

                            final categories = snapshot.data ?? [];

                            if (categories.isEmpty) {
                              return const Text('No categories available');
                            }

                            return DropdownButtonFormField<int>(
                              initialValue: _selectedCategoryId,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              items: categories.map((category) {
                                return DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategoryId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a category';
                                }

                                return null;
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            child: _isSaving
                                ? const CircularProgressIndicator()
                                : const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
