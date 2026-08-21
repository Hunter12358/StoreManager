import 'package:dio/dio.dart';
import 'package:store_manager/core/services/storage_service.dart';

import '../../../core/services/api_service.dart';
import '../models/user_model.dart';

class AuthService {
  final _api = ApiService();

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    final token = response.data['access_token'];

    final profile = await getProfile(token);

    final storage = StorageService();

    await storage.saveToken(token);
    await storage.saveRole(profile.role);
    await storage.saveUserId(profile.userId);

    return token;
  }

  Future<UserModel> getProfile(String token) async {
    final response = await _api.dio.get(
      '/auth/profile',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return UserModel.fromJson(response.data);
  }
}
