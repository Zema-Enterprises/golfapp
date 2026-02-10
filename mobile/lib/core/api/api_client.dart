import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import '../storage/secure_storage.dart';
import 'api_exceptions.dart';
import 'auth_interceptor.dart';

/// API configuration
class ApiConfig {
  ApiConfig._();

  /// Uses API_BASE_URL from --dart-define, falls back to localhost for dev
  static const String baseUrl = EnvConfig.apiBaseUrl;
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

/// Main API client using Dio
class ApiClient {
  late final Dio _dio;
  final SecureStorageService _storage;

  ApiClient({required SecureStorageService storage}) : _storage = storage {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(_storage),
      RefreshTokenInterceptor(
        dio: _dio,
        storage: _storage,
        baseUrl: ApiConfig.baseUrl,
      ),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
    ]);
  }

  Dio get dio => _dio;

  // ============================================
  // HTTP Methods
  // ============================================

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool skipAuth = false,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: _buildOptions(options, skipAuth: skipAuth),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool skipAuth = false,
    bool skipRefresh = false,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _buildOptions(options, skipAuth: skipAuth, skipRefresh: skipRefresh),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool skipAuth = false,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _buildOptions(options, skipAuth: skipAuth),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool skipAuth = false,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _buildOptions(options, skipAuth: skipAuth),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool skipAuth = false,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _buildOptions(options, skipAuth: skipAuth),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // Private Helpers
  // ============================================

  Options _buildOptions(Options? options, {bool skipAuth = false, bool skipRefresh = false}) {
    final opts = options ?? Options();
    opts.extra = {...?opts.extra, 'skipAuth': skipAuth, 'skipRefresh': skipRefresh};
    return opts;
  }

  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(message: 'Connection timeout');

      case DioExceptionType.connectionError:
        return const NetworkException(message: 'No internet connection');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        final message = data is Map ? data['message'] ?? 'Error' : 'Error';

        switch (statusCode) {
          case 401:
            return UnauthorizedException(message: message);
          case 403:
            return ForbiddenException(message: message);
          case 404:
            return NotFoundException(message: message);
          case 422:
            return ValidationException(
              message: message,
              errors: data is Map ? _parseValidationErrors(data) : null,
            );
          case 500:
          case 502:
          case 503:
            return ServerException(message: message);
          default:
            return ApiException(message: message, statusCode: statusCode);
        }

      case DioExceptionType.cancel:
        return const ApiException(message: 'Request cancelled');

      default:
        return const NetworkException(message: 'Unknown error occurred');
    }
  }

  Map<String, List<String>>? _parseValidationErrors(Map<dynamic, dynamic> data) {
    final errors = data['errors'];
    if (errors is Map) {
      return errors.map(
        (key, value) => MapEntry(
          key.toString(),
          (value is List) ? value.map((e) => e.toString()).toList() : [value.toString()],
        ),
      );
    }
    return null;
  }
}

/// Provider for API client
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage: storage);
});
