import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../layout/screens/app_shell.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _service = ProductService();
  final _changeController = TextEditingController();
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late Future<Product> _product;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _product = _service.getProduct(widget.productId);
  }

  Future<void> _adjustStock() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final product = await _service.adjustStock(
        id: widget.productId,
        quantityChange: int.parse(_changeController.text),
        reason: _reasonController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _product = Future.value(product);
        _changeController.clear();
        _reasonController.clear();
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock updated')),
      );
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      final message = error.response?.data is Map
          ? error.response?.data['message']?.toString()
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Stock update failed')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock update failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: FutureBuilder<Product>(
        future: _product,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Failed to load product'));
          }

          final product = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text('Category: ${product.categoryName}'),
                    Text('Unit: ${product.unit}'),
                    Text('Selling price: ${product.sellingPrice.toStringAsFixed(2)}'),
                    Text('Current quantity: ${product.quantity}'),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Stock adjustment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _changeController,
                                keyboardType: const TextInputType.numberWithOptions(signed: true),
                                decoration: const InputDecoration(labelText: 'Quantity change', hintText: '20 or -5', border: OutlineInputBorder()),
                                validator: (value) {
                                  final change = int.tryParse(value ?? '');
                                  if (change == null || change == 0) return 'Enter a non-zero whole number';
                                  if (product.quantity + change < 0) return 'Cannot subtract more than available stock';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _reasonController,
                                decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()),
                                validator: (value) => value == null || value.trim().isEmpty ? 'Enter a reason' : null,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _adjustStock,
                                  child: _isSaving ? const CircularProgressIndicator() : const Text('Submit adjustment'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}