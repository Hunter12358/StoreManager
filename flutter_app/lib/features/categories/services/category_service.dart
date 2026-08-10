import '../models/category.dart';
import '../../../core/services/api_service.dart';

class CategoryService {
  final _api = ApiService();

  Future<List<Category>> getCategories() async {
    final response = await _api.dio.get('/categories');

    return (response.data as List)
        .map((json) => Category.fromJson(json))
        .toList();
  }

  Future<void> createCategory({
    required String name,
    required String description,
  }) async {
    await _api.dio.post(
      '/categories',
      data: {'name': name, 'description': description},
    );
  }

  Future<void> deleteCategory(int id) async {
    await _api.dio.delete('/categories/$id');
  }

  Future<Category> getCategory(int id) async {
    final response = await _api.dio.get('/categories/$id');

    return Category.fromJson(response.data);
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    required String description,
  }) async {
    await _api.dio.put(
      '/categories/$id',
      data: {'name': name, 'description': description},
    );
  }
}
