import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/storage/storage_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiClient(storageService: storageService);
});

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'ApiException: $message (code: $statusCode)';
}

class ApiClient {
  late final Dio _dio;
  final StorageService _storageService;

  ApiClient({required StorageService storageService})
      : _storageService = storageService {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            print('🌐 [API REQ] ${options.method} -> ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
                '✅ [API RES] ${response.statusCode} <- ${response.requestOptions.uri}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            final status = e.response?.statusCode ?? 'NETWORK/CORS_FAIL';
            print('❌ [API ERR] Status: $status <- ${e.requestOptions.uri}');
            if (e.response?.data != null) {
              print('   Message: ${e.response?.data}');
            } else if (e.message != null) {
              print(
                  '   Detail: ${e.message} (Is backend running at ${ApiEndpoints.baseUrl}?)');
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(path,
          queryParameters: queryParameters, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(path,
          data: data, queryParameters: queryParameters, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(path,
          data: data, queryParameters: queryParameters, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(path,
          data: data, queryParameters: queryParameters, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- Multipart Form Data Upload (for Avatars, Voice Notes) ---
  Future<dynamic> uploadMultipart(
    String path, {
    required Map<String, dynamic> fields,
    required Map<String, File> files,
    String method = 'POST',
  }) async {
    try {
      final formDataMap = <String, dynamic>{...fields};

      for (var entry in files.entries) {
        final file = entry.value;
        final filename = file.path.split('/').last;
        formDataMap[entry.key] = await MultipartFile.fromFile(
          file.path,
          filename: filename,
        );
      }

      final formData = FormData.fromMap(formDataMap);

      final options = Options(
        method: method,
        headers: {'Content-Type': 'multipart/form-data'},
      );

      final response =
          await _dio.request(path, data: formData, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    String message = 'An unexpected error occurred.';
    Map<String, dynamic>? errors;

    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('message')) {
        message = data['message'].toString();
      }
      if (data.containsKey('errors') &&
          data['errors'] is Map<String, dynamic>) {
        errors = data['errors'] as Map<String, dynamic>;
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timed out. Please check your network.';
    } else if (error.error is SocketException) {
      message =
          'Could not connect to server. Please ensure backend is running.';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }
}
