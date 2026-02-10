import '../../../core/api/api_client.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/storage/secure_storage.dart';
import 'user.dart';

/// Auth repository for API calls
class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthRepository({
    required ApiClient apiClient,
    required SecureStorageService storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  /// Register a new user
  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {'email': email, 'password': password},
      skipAuth: true,
    );

    final data = response.data['data'];
    final authResponse = AuthResponse.fromJson(data);
    await _saveTokens(authResponse);
    // Extract hasPin from user.parent.hasPin
    final hasPin = data['user']?['parent']?['hasPin'] == true;
    if (hasPin) {
      await _storage.markPinSet();
    }
    return authResponse;
  }

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {'email': email, 'password': password},
      skipAuth: true,
    );

    final data = response.data['data'];
    final authResponse = AuthResponse.fromJson(data);
    await _saveTokens(authResponse);
    // Extract hasPin from user.parent.hasPin
    final hasPin = data['user']?['parent']?['hasPin'] == true;
    if (hasPin) {
      await _storage.markPinSet();
    }
    return authResponse;
  }

  /// Get current user profile
  Future<User> getCurrentUser() async {
    final response = await _apiClient.get('/auth/me');
    return User.fromJson(response.data['data']['user']);
  }

  /// Logout and clear tokens
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } finally {
      await _storage.clearAuth();
    }
  }

  /// Check if user has a valid session
  Future<bool> hasValidSession() async {
    return _storage.hasValidSession();
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post(
      '/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  /// Update current user profile
  Future<User> updateProfile({String? email}) async {
    final response = await _apiClient.patch(
      '/auth/me',
      data: {'email': email},
    );
    return User.fromJson(response.data['data']['user']);
  }

  // ============================================
  // PIN Methods
  // ============================================

  /// Set initial PIN for parent
  Future<void> setPin(String pin) async {
    await _apiClient.post(
      '/auth/set-pin',
      data: {'pin': pin},
    );
  }

  /// Verify parent PIN
  /// Uses skipRefresh to prevent 401 (wrong PIN) from triggering token refresh
  Future<bool> verifyPin(String pin) async {
    try {
      final response = await _apiClient.post(
        '/auth/verify-pin',
        data: {'pin': pin},
        skipRefresh: true,
      );
      return response.data['data']['verified'] == true;
    } on UnauthorizedException {
      // 401 from wrong PIN — not an auth issue
      return false;
    }
  }

  /// Change existing PIN
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    await _apiClient.patch(
      '/auth/change-pin',
      data: {
        'currentPin': currentPin,
        'newPin': newPin,
      },
    );
  }

  /// Save tokens to secure storage
  Future<void> _saveTokens(AuthResponse response) async {
    await _storage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await _storage.saveUserId(response.user.id);
  }
}
