import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/services/storage_service.dart';
import '../../layout/screens/app_shell.dart';
import '../../products/models/product.dart';
import '../../products/services/product_service.dart';
import '../services/sale_service.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _CartLine {
  final Product product;
  int quantity;

  _CartLine({required this.product, required this.quantity});

  double get total => product.sellingPrice * quantity;
}

class _PosScreenState extends State<PosScreen> {
  final _productService = ProductService();
  final _saleService = SaleService();
  final _storage = StorageService();
  final _searchController = TextEditingController();

  late Future<List<Product>> _products;
  final List<_CartLine> _cart = [];
  String _search = '';
  String _paymentMethod = 'Cash';
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _products = _productService.getProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double get _total => _cart.fold(0, (sum, line) => sum + line.total);

  void _addToCart(Product product) {
    if (product.quantity < 1) {
      _showMessage('${product.name} is out of stock');
      return;
    }

    setState(() {
      final matching = _cart.where((line) => line.product.id == product.id);
      if (matching.isEmpty) {
        _cart.add(_CartLine(product: product, quantity: 1));
      } else if (matching.first.quantity < product.quantity) {
        matching.first.quantity++;
      }
    });
  }

  void _changeQuantity(_CartLine line, int change) {
    setState(() {
      final nextQuantity = line.quantity + change;
      if (nextQuantity <= 0) {
        _cart.remove(line);
      } else if (nextQuantity <= line.product.quantity) {
        line.quantity = nextQuantity;
      }
    });
  }

  Future<void> _completeSale() async {
    if (_cart.isEmpty || _isCompleting) return;

    final cashierId = await _storage.getUserId();
    if (cashierId == null) {
      _showMessage('Your session has no cashier ID. Please sign in again.');
      return;
    }

    setState(() => _isCompleting = true);
    try {
      await _saleService.completeSale(
        cashierId: cashierId,
        items: _cart
            .map(
              (line) => {
                'productId': line.product.id,
                'quantity': line.quantity,
                'unitPrice': line.product.sellingPrice,
              },
            )
            .toList(),
      );

      if (!mounted) return;
      setState(() {
        _cart.clear();
        _products = _productService.getProducts();
      });
      _showMessage('Sale completed successfully');
    } catch (error) {
      if (mounted) _showMessage(_errorMessage(error));
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  List<Product> _filteredProducts(List<Product> products) {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return products;
    return products
        .where((product) => product.name.toLowerCase().contains(query))
        .toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      final message = error.response?.data is Map
          ? error.response?.data['message']
          : null;
      if (message is String) return message;
      if (message is List && message.isNotEmpty) return message.join(', ');
    }
    return 'Could not complete the sale';
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: FutureBuilder<List<Product>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load products'));
          }

          final products = _filteredProducts(snapshot.data ?? []);
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final productPane = _buildProductPane(products);
              final cartPane = _buildCartPane();

              return Padding(
                padding: const EdgeInsets.all(20),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: productPane),
                          const SizedBox(width: 20),
                          SizedBox(width: 390, child: cartPane),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(child: productPane),
                          const SizedBox(height: 20),
                          SizedBox(height: 430, child: cartPane),
                        ],
                      ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductPane(List<Product> products) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Products', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _search = value),
              decoration: const InputDecoration(
                labelText: 'Search by product name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text('No matching products'))
                  : ListView.separated(
                      itemCount: products.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ListTile(
                          onTap: () => _addToCart(product),
                          leading: const CircleAvatar(
                            child: Icon(Icons.inventory_2),
                          ),
                          title: Text(product.name),
                          subtitle: Text(
                            '${product.unit} • ${product.quantity} available',
                          ),
                          trailing: Text(
                            '\$${product.sellingPrice.toStringAsFixed(2)}',
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

  Widget _buildCartPane() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current sale',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _cart.isEmpty
                  ? const Center(child: Text('Click a product to add it'))
                  : ListView.builder(
                      itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        final line = _cart[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(line.product.name),
                          subtitle: Text('\$${line.total.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _changeQuantity(line, -1),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text('${line.quantity}'),
                              IconButton(
                                onPressed: () => _changeQuantity(line, 1),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment method',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'Card', child: Text('Card')),
                DropdownMenuItem(value: 'Mobile', child: Text('Mobile')),
              ],
              onChanged: (value) =>
                  setState(() => _paymentMethod = value ?? 'Cash'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _cart.isEmpty || _isCompleting
                    ? null
                    : _completeSale,
                icon: _isCompleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.point_of_sale),
                label: Text(_isCompleting ? 'Completing...' : 'Complete sale'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
