import '../../../core/services/api_service.dart';

class SaleService {
  final _api = ApiService();

  Future<void> completeSale({
    required int cashierId,
    required List<Map<String, dynamic>> items,
  }) async {
    await _api.dio.post(
      '/api/sales',
      data: {'cashierId': cashierId, 'items': items},
    );
  }
}
