import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config.dart';
import 'errors.dart';
import 'token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((_) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return ApiClient(storage);
});

class ApiClient {
  final TokenStorage _storage;
  late final Dio _dio;

  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBase,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {'Accept': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.access;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      return _map(res.data);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {Object? body}) async {
    try {
      final res = await _dio.post(path, data: body);
      return _map(res.data);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> put(String path, {Object? body, Options? options}) async {
    try {
      final res = await _dio.put(path, data: body, options: options);
      return _map(res.data);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> patch(String path, {Object? body}) async {
    try {
      final res = await _dio.patch(path, data: body);
      return _map(res.data);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final res = await _dio.delete(path);
      return _map(res.data);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  Map<String, dynamic> _map(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'data': data};
  }
}
