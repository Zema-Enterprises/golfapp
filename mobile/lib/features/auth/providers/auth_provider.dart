import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/storage/secure_storage.dart';
import '../data/auth_data.dart';

/// Auth state enum
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Auth state model
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final bool hasPinSet;
  final bool isNewUser;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.hasPinSet = false,
    this.isNewUser = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? hasPinSet,
    bool? isNewUser,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      hasPinSet: hasPinSet ?? this.hasPinSet,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get needsPinSetup => isAuthenticated && !hasPinSet;
}

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SecureStorageService _storage;

  AuthNotifier({
    required AuthRepository repository,
    required SecureStorageService storage,
  })  : _repository = repository,
        _storage = storage,
        super(const AuthState());

  /// Check if user has existing session
  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final hasSession = await _storage.hasValidSession();
      if (hasSession) {
        final user = await _repository.getCurrentUser();
        final hasPinSet = await _storage.hasPinSet();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          hasPinSet: hasPinSet,
          isNewUser: false,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      await _storage.clearAuth();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// Login with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final response = await _repository.login(
        email: email,
        password: password,
      );
      final hasPinSet = await _storage.hasPinSet();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        hasPinSet: hasPinSet,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'An unexpected error occurred',
      );
    }
  }

  /// Register new user
  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      final response = await _repository.register(
        email: email,
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        hasPinSet: false,
        isNewUser: true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'An unexpected error occurred',
      );
    }
  }

  /// Mark PIN as set (called after successful PIN setup)
  Future<void> markPinSet() async {
    await _storage.markPinSet();
    state = state.copyWith(hasPinSet: true, isNewUser: false);
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      await _repository.logout();
    } finally {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth state notifier provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    repository: ref.watch(authRepositoryProvider),
    storage: ref.watch(secureStorageProvider),
  );
});
