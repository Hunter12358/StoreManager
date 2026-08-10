import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../layout/screens/app_shell.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _service = ProductService();

  late Future<List<Product>> _products;

  @override
  void initState() {
    super.initState();
    _products = _service.getProducts();
  }

  void _refreshProducts() {
    setState(() {
      _products = _service.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final created = await context.push<bool>('/products/new');

                    if (created == true) {
                      _refreshProducts();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Product'),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _products,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load products'));
                  }

                  final products = snapshot.data ?? [];

                  if (products.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }

                  return SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Unit')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: products.map((product) {
                        return DataRow(
                          cells: [
                            DataCell(Text(product.name)),
                            DataCell(Text(product.categoryName)),
                            DataCell(Text(product.unit)),
                            DataCell(
                              Text(product.sellingPrice.toStringAsFixed(2)),
                            ),
                            DataCell(Text(product.quantity.toString())),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      final updated = await context.push<bool>(
                                        '/products/${product.id}/edit',
                                      );

                                      if (updated == true) {
                                        _refreshProducts();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Delete Product'),
                                            content: const Text(
                                              'Are you sure?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context, true);
                                                },
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirmed == true) {
                                        await _service.deleteProduct(
                                          product.id,
                                        );

                                        _refreshProducts();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
