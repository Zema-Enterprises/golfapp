import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

/// Interceptor that attaches the JWT access token to requests
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public endpoints
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    try {
      final token = await _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Storage read can fail on web (Web Crypto OperationError).
      // Proceed without auth header; server will return 401 if needed.
    }

    handler.next(options);
  }
}

/// Interceptor that handles token refresh on 401 errors
class RefreshTokenInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorageService _storage;
  final String _baseUrl;
  bool _isRefreshing = false;

  RefreshTokenInterceptor({
    required Dio dio,
    required SecureStorageService storage,
    required String baseUrl,
  })  : _dio = dio,
        _storage = storage,
        _baseUrl = baseUrl;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Skip refresh for endpoints where 401 means business logic (e.g. wrong PIN)
    final skipRefresh = err.requestOptions.extra['skipRefresh'] == true;

    if (err.response?.statusCode == 401 && !_isRefreshing && !skipRefresh) {
      _isRefreshing = true;

      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken == null) {
          await _storage.clearAuth();
          return handler.reject(err);
        }

        // Create a new Dio instance to avoid interceptor loops
        final refreshDio = Dio(BaseOptions(baseUrl: _baseUrl));
        final response = await refreshDio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200) {
          final data = response.data is Map && response.data['data'] != null
              ? response.data['data']
              : response.data;
          final newAccessToken = data['accessToken'] as String;
          final newRefreshToken = data['refreshToken'] as String;

          await _storage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );

          // Retry the original request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';

          final retryResponse = await _dio.fetch(opts);
          return handler.resolve(retryResponse);
        }
      } catch (e) {
        await _storage.clearAuth();
      } finally {
        _isRefreshing = false;
      }
    }

    handler.next(err);
  }
}
