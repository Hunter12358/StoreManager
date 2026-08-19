
import '../../../core/services/api_service.dart';
import '../models/product.dart';

class ProductService {
  final _api = ApiService();

  Future<List<Product>> getProducts() async {
    final response = await _api.dio.get('/products');

    return (response.data as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }

  Future<void> createProduct({
    required String name,
    required String unit,
    required double sellingPrice,
    required int quantity,
    required int categoryId,
  }) async {
    await _api.dio.post(
      '/products',
      data: {
        'name': name,
        'unit': unit,
        'sellingPrice': sellingPrice,
        'quantity': quantity,
        'categoryId': categoryId,
      },
    );
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required String unit,
    required double sellingPrice,
    required int quantity,
    required int categoryId,
  }) async {
    await _api.dio.put(
      '/products/$id',
      data: {
        'name': name,
        'unit': unit,
        'sellingPrice': sellingPrice,
        'quantity': quantity,
        'categoryId': categoryId,
      },
    );
  }

  Future<void> deleteProduct(int id) async {
    await _api.dio.delete('/products/$id');
  }

  Future<Product> getProduct(int id) async {
    final response = await _api.dio.get('/products/$id');

    return Product.fromJson(response.data);
  }

  Future<Product> adjustStock({
    required int id,
    required int quantityChange,
    required String reason,
  }) async {
    final response = await _api.dio.patch(
      '/stock/$id',
      data: {
        'quantityChange': quantityChange,
        'reason': reason,
      },
    );

    return Product.fromJson(response.data);
  }
}
