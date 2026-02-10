import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keys for secure storage
class StorageKeys {
  StorageKeys._();

  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const userId = 'user_id';
  static const pinSet = 'pin_set';

}

/// Secure storage for auth tokens and sensitive data.
/// On mobile: uses FlutterSecureStorage (encrypted).
/// On web: uses a simple in-memory map (tokens are session-scoped).
class SecureStorageService {
  final FlutterSecureStorage? _nativeStorage;

  /// In-memory storage for web platform where Web Crypto is unreliable.
  static final Map<String, String> _webStore = {};

  SecureStorageService({FlutterSecureStorage? storage})
      : _nativeStorage = kIsWeb
            ? null
            : (storage ??
                const FlutterSecureStorage(
                  aOptions: AndroidOptions(encryptedSharedPreferences: true),
                  iOptions:
                      IOSOptions(accessibility: KeychainAccessibility.first_unlock),
                ));

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      return _webStore[key];
    }
    return _nativeStorage!.read(key: key);
  }

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      _webStore[key] = value;
      return;
    }
    await _nativeStorage!.write(key: key, value: value);
  }

  Future<void> _delete(String key) async {
    if (kIsWeb) {
      _webStore.remove(key);
      return;
    }
    await _nativeStorage!.delete(key: key);
  }

  Future<void> _deleteAll() async {
    if (kIsWeb) {
      _webStore.clear();
      return;
    }
    await _nativeStorage!.deleteAll();
  }

  // Token Management
  Future<void> saveAccessToken(String token) async {
    await _write(StorageKeys.accessToken, token);
  }

  Future<String?> getAccessToken() async {
    return _read(StorageKeys.accessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _write(StorageKeys.refreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    return _read(StorageKeys.refreshToken);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  // User ID
  Future<void> saveUserId(String userId) async {
    await _write(StorageKeys.userId, userId);
  }

  Future<String?> getUserId() async {
    return _read(StorageKeys.userId);
  }

  // Clear all auth data
  Future<void> clearAuth() async {
    await _deleteAll();
  }

  // Check if user is logged in
  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // PIN Management
  Future<bool> hasPinSet() async {
    final pinSet = await _read(StorageKeys.pinSet);
    return pinSet == 'true';
  }

  Future<void> markPinSet() async {
    await _write(StorageKeys.pinSet, 'true');
  }

  Future<void> clearPinSet() async {
    await _delete(StorageKeys.pinSet);
  }
}

/// Provider for secure storage service
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
